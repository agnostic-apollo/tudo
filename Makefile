export TUDO_PKG__VERSION := 1.2.0
export TUDO_PKG__ARCH
export TUDO__INSTALL_PREFIX

export TERMUX__NAME := Termux# Default value: `Termux`
export TERMUX__LNAME := termux# Default value: `termux`

export TERMUX_APP__NAME := Termux# Default value: `Termux`
export TERMUX_APP__PACKAGE_NAME := com.termux# Default value: `com.termux`
export TERMUX_APP__DATA_DIR := /data/data/$(TERMUX_APP__PACKAGE_NAME)# Default value: `/data/data/com.termux`

export TERMUX__ROOTFS := $(TERMUX_APP__DATA_DIR)/files# Default value: `/data/data/com.termux/files`
export TERMUX__HOME := $(TERMUX__ROOTFS)/home# Default value: `/data/data/com.termux/files/home`
export TERMUX__PREFIX := $(TERMUX__ROOTFS)/usr# Default value: `/data/data/com.termux/files/usr`

export TERMUX_ENV__S_ROOT := TERMUX_# Default value: `TERMUX_`
export TERMUX_ENV__SS_TERMUX := _# Default value: `_`
export TERMUX_ENV__S_TERMUX := $(TERMUX_ENV__S_ROOT)$(TERMUX_ENV__SS_TERMUX)# Default value: `TERMUX__`
export TERMUX_ENV__SS_TERMUX_APP := APP__# Default value: `APP__`
export TERMUX_ENV__S_TERMUX_APP := $(TERMUX_ENV__S_ROOT)$(TERMUX_ENV__SS_TERMUX_APP)# Default value: `TERMUX_APP__`


# If architecture not set, find it for the compiler based on which
# predefined architecture macro is defined. The `shell` function
# replaces newlines with a space and a literal space cannot be entered
# in a makefile as its used as a splitter, hence $(SPACE) variable is
# created and used for matching.
ifeq ($(TUDO_PKG__ARCH),)
	export override PREDEFINED_MACROS := $(shell $(CC) -x c /dev/null -dM -E)
	override EMPTY :=
	override SPACE := $(EMPTY) $(EMPTY)
	ifneq (,$(findstring $(SPACE)#define __i686__ 1$(SPACE),$(SPACE)$(PREDEFINED_MACROS)$(SPACE)))
		override TUDO_PKG__ARCH := i686
	else ifneq (,$(findstring $(SPACE)#define __x86_64__ 1$(SPACE),$(SPACE)$(PREDEFINED_MACROS)$(SPACE)))
		override TUDO_PKG__ARCH := x86_64
	else ifneq (,$(findstring $(SPACE)#define __aarch64__ 1$(SPACE),$(SPACE)$(PREDEFINED_MACROS)$(SPACE)))
		override TUDO_PKG__ARCH := aarch64
	else ifneq (,$(findstring $(SPACE)#define __arm__ 1$(SPACE),$(SPACE)$(PREDEFINED_MACROS)$(SPACE)))
		override TUDO_PKG__ARCH := arm
	else ifneq (,$(findstring $(SPACE)#define __riscv 1$(SPACE),$(SPACE)$(PREDEFINED_MACROS)$(SPACE)))
		override TUDO_PKG__ARCH := riscv64
	else
        $(error Unsupported package arch)
	endif
endif



export override BUILD_DIR := build# Default value: `build`

export override BUILD_OUTPUT_DIR := $(BUILD_DIR)/output# Default value: `build/output`

export override PREFIX_BUILD_OUTPUT_DIR := $(BUILD_OUTPUT_DIR)/usr# Default value: `build/output/usr`
export override BIN_BUILD_OUTPUT_DIR := $(PREFIX_BUILD_OUTPUT_DIR)/bin# Default value: `build/output/usr/bin`
export override LIBEXEC_BUILD_OUTPUT_DIR := $(PREFIX_BUILD_OUTPUT_DIR)/libexec# Default value: `build/output/usr/libexec`
export override TESTS_BUILD_OUTPUT_DIR := $(LIBEXEC_BUILD_OUTPUT_DIR)/installed-tests/tudo# Default value: `build/output/usr/libexec/installed-tests/tudo`
export override SHARE_BUILD_OUTPUT_DIR := $(PREFIX_BUILD_OUTPUT_DIR)/share# Default value: `build/output/usr/share`
export override EXAMPLES_BUILD_OUTPUT_DIR := $(SHARE_BUILD_OUTPUT_DIR)/doc/tudo/examples# Default value: `build/output/usr/share/doc/tudo/examples`

export override PACKAGING_BUILD_OUTPUT_DIR := $(BUILD_OUTPUT_DIR)/packaging# Default value: `build/output/packaging`
export override DEBIAN_PACKAGING_BUILD_OUTPUT_DIR := $(PACKAGING_BUILD_OUTPUT_DIR)/debian# Default value: `build/output/packaging/debian`



export override BUILD_INSTALL_DIR := $(BUILD_DIR)/install# Default value: `build/install`
export override PREFIX_BUILD_INSTALL_DIR := $(BUILD_INSTALL_DIR)/usr# Default value: `build/install/usr`

ifeq ($(TUDO__INSTALL_PREFIX),)
	ifeq ($(DESTDIR)$(PREFIX),)
		override TUDO__INSTALL_PREFIX := $(TERMUX__PREFIX)
	else
		override TUDO__INSTALL_PREFIX := $(DESTDIR)$(PREFIX)
	endif
endif
export TUDO__INSTALL_PREFIX



export override TERMUX__CONSTANTS__SED_ARGS := \
	-e "s%[@]TUDO_PKG__VERSION[@]%$(TUDO_PKG__VERSION)%g" \
	-e "s%[@]TUDO_PKG__ARCH[@]%$(TUDO_PKG__ARCH)%g" \
	-e "s%[@]TERMUX__LNAME[@]%$(TERMUX__LNAME)%g" \
	-e "s%[@]TERMUX_APP__NAME[@]%$(TERMUX_APP__NAME)%g" \
	-e "s%[@]TERMUX_APP__PACKAGE_NAME[@]%$(TERMUX_APP__PACKAGE_NAME)%g" \
	-e "s%[@]TERMUX__ROOTFS[@]%$(TERMUX__ROOTFS)%g" \
	-e "s%[@]TERMUX__HOME[@]%$(TERMUX__HOME)%g" \
	-e "s%[@]TERMUX__PREFIX[@]%$(TERMUX__PREFIX)%g" \
	-e "s%[@]TERMUX_ENV__S_ROOT[@]%$(TERMUX_ENV__S_ROOT)%g" \
	-e "s%[@]TERMUX_ENV__SS_TERMUX[@]%$(TERMUX_ENV__SS_TERMUX)%g" \
	-e "s%[@]TERMUX_ENV__S_TERMUX[@]%$(TERMUX_ENV__S_TERMUX)%g" \
	-e "s%[@]TERMUX_ENV__SS_TERMUX_APP[@]%$(TERMUX_ENV__SS_TERMUX_APP)%g"

define replace-termux-constants
	sed $(TERMUX__CONSTANTS__SED_ARGS) "$1.in" > "$2/$$(basename "$1")"
endef



# - https://www.gnu.org/software/make/manual/html_node/Parallel-Disable.html
.NOTPARALLEL:

all: | pre-build
	@mkdir -p $(BIN_BUILD_OUTPUT_DIR)
	sed $(TERMUX__CONSTANTS__SED_ARGS) "tudo" > "$(BIN_BUILD_OUTPUT_DIR)/tudo"
	chmod 700 "$(BIN_BUILD_OUTPUT_DIR)/tudo"


	@printf "\ntudo: %s\n" "Building tudo.config"
	@mkdir -p $(EXAMPLES_BUILD_OUTPUT_DIR)
	sed $(TERMUX__CONSTANTS__SED_ARGS) "tudo.config" > "$(EXAMPLES_BUILD_OUTPUT_DIR)/tudo.config"


	@printf "\ntudo: %s\n" "Building tudo_tests"
	@mkdir -p $(TESTS_BUILD_OUTPUT_DIR)
	sed $(TERMUX__CONSTANTS__SED_ARGS) "tests/tudo_tests" > "$(TESTS_BUILD_OUTPUT_DIR)/tudo_tests"
	chmod 700 "$(TESTS_BUILD_OUTPUT_DIR)/tudo_tests"


	@printf "\ntudo: %s\n" "Building packaging/debian/*"
	@mkdir -p $(DEBIAN_PACKAGING_BUILD_OUTPUT_DIR)
	find packaging/debian -mindepth 1 -maxdepth 1 -type f -name "*.in" -exec sh -c \
		'sed $(TERMUX__CONSTANTS__SED_ARGS) "$$1" > $(DEBIAN_PACKAGING_BUILD_OUTPUT_DIR)/"$$(basename "$$1" | sed "s/\.in$$//")"' sh "{}" \;
	find $(DEBIAN_PACKAGING_BUILD_OUTPUT_DIR) -mindepth 1 -maxdepth 1 -type f \
		-regextype posix-extended -regex "^.*/(postinst|postrm|preinst|prerm)$$" \
		-exec chmod 700 {} \;
	find $(DEBIAN_PACKAGING_BUILD_OUTPUT_DIR) -mindepth 1 -maxdepth 1 -type f \
		-regextype posix-extended -regex "^.*/(config|conffiles|templates|triggers|clilibs|fortran_mod|runit|shlibs|starlibs|symbols)$$" \
		-exec chmod 600 {} \;


	@printf "\ntudo: %s\n\n" "Build tudo successful"



pre-build: | clean
	@printf "tudo: %s\n" "Building tudo"
	@mkdir -p $(BUILD_OUTPUT_DIR)

clean:
	rm -rf $(BUILD_OUTPUT_DIR)

install:
	@printf "tudo: %s\n" "Installing tudo in $(TUDO__INSTALL_PREFIX)"

	install -d $(TUDO__INSTALL_PREFIX)/bin
	cp -a $(BIN_BUILD_OUTPUT_DIR)/tudo $(TUDO__INSTALL_PREFIX)/bin/


	install -d $(TUDO__INSTALL_PREFIX)/share/doc/tudo/examples
	cp -a $(EXAMPLES_BUILD_OUTPUT_DIR)/tudo.config $(TUDO__INSTALL_PREFIX)/share/doc/tudo/examples/


	install -d $(TUDO__INSTALL_PREFIX)/libexec/installed-tests/tudo
	cp -a $(TESTS_BUILD_OUTPUT_DIR)/tudo_tests $(TUDO__INSTALL_PREFIX)/libexec/installed-tests/tudo/

	@printf "\ntudo: %s\n\n" "Install tudo successful"

uninstall:
	@printf "tudo: %s\n" "Uninstalling tudo from $(TUDO__INSTALL_PREFIX)"

	rm -f $(TUDO__INSTALL_PREFIX)/bin/tudo
	rm -f $(TUDO__INSTALL_PREFIX)/share/doc/tudo/examples/tudo.config
	rm -f $(TUDO__INSTALL_PREFIX)/libexec/installed-tests/tudo/tudo_tests

	@printf "\ntudo: %s\n\n" "Uninstall tudo successful"



packaging-debian-build: all
	termux-create-package $(DEBIAN_PACKAGING_BUILD_OUTPUT_DIR)/tudo-package.json



.PHONY: all pre-build clean install uninstall packaging-debian-build
