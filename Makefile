include Make.config

ROM := $(NAME).smc
PATCH := $(NAME).bps
BASEROM := baserom/baserom.smc
BASEPATCH := baserom/baserom.bps
SMW := baserom/smw.smc

ASAR := $(shell test -d asar && find asar -type f | sed 's/ /\\ /g')
BLOCKS := $(shell test -d blocks && find blocks -type f | sed 's/ /\\ /g')
GAMEMODE := $(shell test -d gamemode && find gamemode -type f | sed 's/ /\\ /g')
LEVELS := $(shell test -d levels && find levels -type f | sed 's/ /\\ /g')
MAP16 := $(shell test -d map16 && find map16 -type f | sed 's/ /\\ /g')
MUSIC := $(shell test -d music && find music -type f | sed 's/ /\\ /g')
SAMPLES := $(shell test -d samples && find samples -type f | sed 's/ /\\ /g')
SPRITES := $(shell test -d sprites && find sprites -type f | sed 's/ /\\ /g')

rom: $(ROM)
.PHONY: rom

patch: $(PATCH)
.PHONY: patch

run: $(ROM)
	snes9x -paddev1 /dev/input/js0 $<
.PHONY: run

# not depending on LEVELS or MAP16 because those are typically saved from
# within lunar magic itself, so we want to avoid "save rom" -> "save level
# file" -> "make run" causing a rebuild
$(ROM): $(BASEROM) $(ASAR) $(BLOCKS) $(GAMEMODE) $(MUSIC) $(SAMPLES) $(SPRITES) list-addmusick.txt list-gps.txt list-pixi.txt list-tile.txt list-uberasm.txt
	@if [ -e '$@' ]; then cp $@ $@.bak; fi
	@cp $< $@
	@for file in $(ASAR); do bin/asar "$$file" $@; done
	@echo | bin/uberasm list-uberasm.txt
	@mkdir -p sysLMRestore
	@cp baserom/smw.smc sysLMRestore/smwOrig.smc
	@bin/lunar-magic-cli -ExportGFX $@
	@bin/tile-editor list-tile.txt
	@bin/lunar-magic-cli -ImportGFX $@
	@# we need to encourage lunar magic to apply the vram optimization patch
	@# even if we don't have any levels to import, and i'm not sure of a
	@# better way to do it
	@if [ -n "$(LEVELS)" ]; then bin/lunar-magic-cli -ImportMultLevels $@ levels; else bin/lunar-magic-cli -ExportLevel $@ tmp-level.mwl 100 && bin/lunar-magic-cli -ImportLevel $@ tmp-level.mwl && rm -f tmp-level.mwl; fi
	@for file in $(MAP16); do bin/lunar-magic-cli -ImportMap16 $@ "$$file" "$$(basename $$file .map16)"; done
	@bin/pixi -l list-pixi.txt $@
	@bin/gps -l list-gps.txt $@
	@bin/addmusick $@

$(PATCH): $(SMW) $(ROM)
	@bin/flips $^ $@

$(BASEROM): $(SMW) $(wildcard $(BASEPATCH))
	@if [ -e "$(BASEPATCH)" ]; then bin/flips --apply $(BASEPATCH) $(SMW) $@; else cp $(SMW) $@; fi

.gitignore: Makefile
	@rm -f $@
	@echo /Graphics >> $@
	@echo /sysLMRestore >> $@
	@echo /$(ROM) >> $@
	@echo /$(ROM).bak >> $@
	@echo /$(PATCH) >> $@
	@echo /$(NAME).extmod >> $@
	@echo /$(NAME).mw2 >> $@
	@echo /$(NAME).mwt >> $@
	@echo /$(NAME).s16 >> $@
	@echo /$(NAME).ssc >> $@
	@echo /$(NAME).dsc >> $@
	@echo /$(NAME).msc >> $@

clean:
	@rm -rf $(BASEROM) $(ROM) $(PATCH) $(NAME).{extmod,mw2,mwt,s16,ssc,dsc,msc} Graphics sysLMRestore tmp-level.mwl
.PHONY: clean

get-name:
	@echo $(NAME)
.PHONY: get-name

get-docker:
	@echo $(DOCKER)
.PHONY: get-docker

get-addmusick-url:
	@echo $(ADDMUSICK_URL)
.PHONY: get-addmusick-url

get-asar-url:
	@echo $(ASAR_URL)
.PHONY: get-asar-url

get-flips-url:
	@echo $(FLIPS_URL)
.PHONY: get-flips-url

get-gps-url:
	@echo $(GPS_URL)
.PHONY: get-gps-url

get-lunar-magic-url:
	@echo $(LUNAR_MAGIC_URL)
.PHONY: get-lunar-magic-url

get-pixi-url:
	@echo $(PIXI_URL)
.PHONY: get-pixi-url

get-tile-editor-url:
	@echo $(TILE_EDITOR_URL)
.PHONY: get-tile-editor-url

get-uberasm-url:
	@echo $(UBERASM_URL)
.PHONY: get-uberasm-url
