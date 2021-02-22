ifneq ($(BUILD_NO_PARALLEL),1)
default $(MAKECMDGOALS):
	make -j $(shell nproc) BUILD_NO_PARALLEL=1 $(MAKECMDGOALS)
else

CONFIG ?= undefined
PATCHED ?= y
BUILD = build-$(CONFIG)-$(PATCHED)
BZIP := $(shell which pbzip2 || which bzip2)

CONFIGS += $(shell ls config | cut -d. -f1)
TEAL = $(shell tput setaf 6 2>/dev/null)
YELLOW = $(shell tput setaf 3 2>/dev/null)
GREEN = $(shell tput setaf 2 2>/dev/null)
PURPLE = $(shell tput setaf 5 2>/dev/null)
NOCOLOR = $(shell tput sgr0 2>/dev/null)

include config/$(CONFIG).mk

PROFILE_BASE = $(shell echo $(PROFILE) | cut -d+ -f1)
PROFILE_ARCH = $(shell echo $(PROFILE) | tr '+' ' ' | cut -d' ' -f2- | xargs -n1 echo --arch= | tr -d ' ')
ifeq ($(IMAGE_SIGN),1)
PROFILE_ARCH += --arch=SECBOOT
endif
IMPLDIR = $(BUILD)/bcmdrivers/broadcom/net/wl/impl$(IMPLVER)
PATCHDIR = $(shell test -e .$(BUILD) && echo .$(BUILD) || echo $(BUILD))/patches
export OPENSYNC_TARGET

help: ## this help message
	@echo provide "$(YELLOW)BUILD_NO_PARALLEL=1$(NOCOLOR)" to not run parallel jobs automatically
	@echo
	@echo provide "$(GREEN)OPENSYNC_SRC$(NOCOLOR)=~/path/to/opensync" to OpenSync root directory
	@echo
	@echo available CONFIG= are:
	@echo $(CONFIGS) | tr ' ' '\n' | sort | xargs -n1 printf "$(YELLOW)%s$(NOCOLOR)\\n"
	@echo
	@echo available make targets are:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {printf "$(TEAL)%-30s$(NOCOLOR) %s\n", $$1, $$NF}' $(MAKEFILE_LIST)
	@echo
	@echo examples:
	@echo "   docker/dock-run make CONFIG=$(YELLOW)XYZ$(NOCOLOR) $(GREEN)OPENSYNC_SRC$(NOCOLOR)=~/path/to/opensync $(TEAL)build$(NOCOLOR)"
	@echo "   docker/dock-run make CONFIG=$(YELLOW)XYZ$(NOCOLOR) $(GREEN)OPENSYNC_SRC$(NOCOLOR)=~/path/to/opensync $(TEAL)compile$(NOCOLOR)"
	@echo "   docker/dock-run make CONFIG=$(YELLOW)XYZ$(NOCOLOR) $(GREEN)OPENSYNC_SRC$(NOCOLOR)=~/path/to/opensync $(TEAL)compile/opensync$(NOCOLOR)"
	@echo "   docker/dock-run make CONFIG=$(YELLOW)XYZ$(NOCOLOR) $(GREEN)OPENSYNC_SRC$(NOCOLOR)=~/path/to/opensync $(TEAL)compile/opensync/menuconfig$(NOCOLOR)"
	@echo

build: ## unpack and build a CONFIG=
	make prepare
	make compile

compile: compile/dongle compile/dongle-mfg ## rebuild unpacked CONFIG=
	make -C $(BUILD) PROFILE=$(PROFILE) BUILD_WL_PARALLEL=1 PCIEFD_TARGETS_LIST=

compile/dongle: ## rebuild unpacked CONFIG='s wireless dongle only
	make -j$(shell nproc) -C $(IMPLDIR)/main/components/router WLTEST=0 LINUX_VERSION=4_1_0 ARCH=arm PLT=arm PCIEFD_TARGETS_LIST="$(WLCHIPS)" pciefd

compile/dongle-mfg: ## rebuild unpacked CONFIG='s wireless dongle mfg only
	make -j$(shell nproc)  -C $(IMPLDIR)/main/components/router WLTEST=1 LINUX_VERSION=4_1_0 ARCH=arm PLT=arm PCIEFD_TARGETS_LIST="$(WLCHIPS)" PCIEFD_IMAGE_DIR=../../../sys/src/dongle/mfg pciefd

compile/opensync: ## rebuild unpacked CONFIG='s opensync code only
	make -C $(BUILD)/userspace/public/apps/opensync PROFILE=$(PROFILE)

compile/opensync/%: ## rebuild unpacked CONFIG='s opensync custom goal % (eg. clean, menuconfig,...)
	make -C $(BUILD)/userspace/public/apps/opensync PROFILE=$(PROFILE) $(patsubst compile/opensync/%,%,$@)

compile/wlan: ## rebuild unpacked CONFIG='s wireless userspace only
	make -C $(BUILD)/userspace/private/apps/wlan/ PROFILE=$(PROFILE)

compile/modules: ## rebuild unpacked CONFIG='s kernel and modules, including wireless drivers
	make -C $(BUILD) PROFILE=$(PROFILE) BUILD_WL_PARALLEL=1 PCIEFD_TARGETS_LIST= modbuild

compile/wrap: ## rebuild unpacked CONFIG='s arbitrary sdk make, use WRAP_PATH= and WRAP_ARGS=
	make -C $(BUILD)/$(WRAP_PATH) PROFILE=$(PROFILE) $(WRAP_ARGS)

compile/hostapd: ## rebuild hostapd in the sdk
	make -C $(BUILD)/bcmdrivers/broadcom/net/wl/impl$(IMPLVER)/main/components/router hostapd

compile/wpa_supplicant: ## rebuild wpa_supplicant in the sdk
	make -C $(BUILD)/bcmdrivers/broadcom/net/wl/impl$(IMPLVER)/main/components/router wpa_supplicant

# SERIES_DIRS is a list of directories that define the order and selection
# of components that are applied using stow for files/ and quit for patches/
# This allows product specific list of files/patches that need to be applied.

# Helper function for finding the matching series dirs
define _FIND_SERIES_DIRS
$(notdir $(wildcard $(addprefix $1,$(strip $(SERIES_DIRS)))))
endef

patch: ## (internal) apply contrib/ to build dir
	# Stow can't overwrite files. We need to do that with some files.
	# so all contrib/files that will be stowed are first removed from target
	# Copying files over has the downside of making it harder to
	# update contrib/files/ back. Stow makes symlinks so modifying files
	# in $(BUILD)/ will change contrib/files/ immediatelly.
	STOW_PKGS="$(call _FIND_SERIES_DIRS,contrib/files/)"; \
		echo stowing: $$STOW_PKGS; \
		for D in $$STOW_PKGS; do find contrib/files/$$D -not -type d -printf ".$(BUILD)/%P\n" | xargs rm -vf; done; \
		[ -z "$$STOW_PKGS" ] || stow -t .$(BUILD) -d contrib/files --no-folding -R $$STOW_PKGS
	# Patches are copied so if there are some changes in $(BUILD)/
	# it is safe to checkout a different commit in git and build it.
	cp -va contrib/patches .$(BUILD)/
	# generate a single series file for quilt from all series files in the tree
	> .$(BUILD)/patches/series
	for D in $(call _FIND_SERIES_DIRS,contrib/patches/); do \
		for DIR in $$D $$D/wl-impl$(IMPLVER); do \
		SERIES_FILE=contrib/patches/$$DIR/series; \
		if [ -e "$$SERIES_FILE" ]; then \
			echo include series: $$SERIES_FILE; \
			sed "s,^,$$DIR/," $$SERIES_FILE >> .$(BUILD)/patches/series; \
		fi; \
	done; done
	cd .$(BUILD) && ( ! quilt series | grep . || quilt push -a )
	# diff patches don't maintain permissions and gendefconfig
	# relies on execute bit, so fixup that
	chmod +x .$(BUILD)/hostTools/scripts/gendefconfig.d/*.conf

$(BUILD): $(shell find config contrib dl docker) Makefile
	rm -rf .$(BUILD)
	test -n "$(TMPFSBUILD)" && ln -sf $(shell mktemp -d) .$(BUILD) || mkdir -p .$(BUILD)
	env SDK=$(SDK) SDK_DATA=$(SDK_DATA) WLAN=$(WLAN) OVS=$(OVS) OVS_DATA=$(OVS_DATA) OVS_PATCH=$(OVS_PATCH) contrib/extract-sdk .$(BUILD)
	find .$(BUILD)/ -name rtecdc.bin -and -not -wholename '*mfg*' -delete
	find .$(BUILD)/ -name rtecdc.bin | grep -vE "$(shell echo $(WLCHIPS) | xargs -n1 | tr '\n' '|' | sed 's/|$$//')" | xargs rm -v
	test "$(PATCHED)" = n || make patch
	cd .$(BUILD) && test -e targets/$(PROFILE)/$(PROFILE) || release/maketargets --out=$(PROFILE) $(PROFILE_ARCH) $(PROFILE_BASE)
	# This is more of a safety measure to avoid losing work in progress.
	! test -e $(BUILD) || mv -f $(BUILD) $(BUILD).old.$(shell date +%Y-%m-%d-%H-%M-%S)
	mv .$(BUILD) $(BUILD)

download: ## (internal) download remote dependencies


prepare: ## (internal) unpack sdk and apply patches
	make $(BUILD)

update: ## copy quilt patches from CONFIG= build dir to contrib/patches/
	rm -rf contrib/patches/*
	cp -va $(PATCHDIR)/* contrib/patches/
	rm -f contrib/patches/series
	for D in $(call _FIND_SERIES_DIRS,contrib/patches/); do \
		for DIR in $$D $$D/wl-impl$(IMPLVER); do \
		SERIES_FILE=contrib/patches/$$DIR/series; \
		if [ -e "$$SERIES_FILE" ]; then \
			echo update series: $$SERIES_FILE; \
			sed -n "\:^$$DIR/[^/]*.patch:s:^$$DIR/\(.*\)$$:\1:p" $(PATCHDIR)/series > $$SERIES_FILE; \
		fi; \
	done; done

clean: ## remove CONFIG='s build dir
	rm -rf $(BUILD) .$(BUILD)

cleanold: ## remove all old (automatically renamed) build dirs
	rm -rf build*.old.*

cleanall: ## remove all build dirs
	rm -rf build*/ .build*/ build* .build*

.PHONY: update clean cleanold cleanall patch prepare
endif # BUILD_NO_PARALLEL
