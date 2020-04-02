PROJECT_DIR   = $(shell readlink -f .)
BUILD_DIR     = "$(PROJECT_DIR)/build"
SOURCE_DIR    = "$(PROJECT_DIR)/src/bash"
VERSION       = $(shell git describe --always --dirty --tags)

.PHONY: default
default: artifact

.PHONY: builddeps
builddeps: builddir
	@echo ' 🔌 Collecting dependencies'

.PHONY: builddir
builddir:
	@mkdir -p $(BUILD_DIR)/artifact

.PHONY: clean
clean:
	@echo " 🛁 Cleaning"
	@rm -frv $(BUILD_DIR)

.PHONY: check
check: builddeps
	@echo " 👮‍ Checking"
	@find $(SOURCE_DIR) -type f -path '*.bash' \
	  | xargs -r shellcheck --color=always --source-path=$(SOURCE_DIR)

.PHONY: test
test: builddir check
	@echo " ✅ Testing"
	@cd $(SOURCE_DIR)
	@shpec

.PHONY: artifact
artifact: builddir test
	@echo " 🔧 Building"
	@find $(SOURCE_DIR) -name '*.bash' -not -name '*_shpec.bash' \
	  | xargs -r -I {} cp -v {} $(BUILD_DIR)/artifact

.PHONY: install
install: artifact
	@echo " 💿 Installing"
	@mkdir -pv /etc/dkms/sign/modules.list.d
	@mkdir -pv /etc/dkms/sign/keys
	@rm -rf /usr/lib/dkms-sign
	@cp -Rv $(BUILD_DIR)/artifact /usr/lib/dkms-sign
	@ln -sfv /usr/lib/dkms-sign/main.bash /usr/sbin/dkms-sign
	@chmod +x /usr/sbin/dkms-sign
