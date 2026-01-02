PROJ	:= lab2
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)
SLASH	:= /

V       := @

#ifndef GCCPREFIX
GCCPREFIX := riscv64-unknown-elf-
#endif

ifndef QEMU
QEMU := /defaultShare/archive/yinbowen/Houjd/study/qemu-4.1.1/riscv64-softmmu/qemu-system-riscv64
endif

ifndef SPIKE
SPIKE := spike
endif

# eliminate default suffix rules
.SUFFIXES: .c .S .h

# delete target files if there is an error (or make is interrupted)
.DELETE_ON_ERROR:

# define compiler and flags
HOSTCC		:= gcc
HOSTCFLAGS	:= -Wall -O2

GDB		:= $(GCCPREFIX)gdb

CC		:= $(GCCPREFIX)gcc
CFLAGS  := -mcmodel=medany -std=gnu99 -Wno-unused -Werror 
CFLAGS	+= -fno-builtin -Wall -O2 -nostdinc $(DEFS)
CFLAGS	+= -fno-stack-protector -ffunction-sections -fdata-sections
CFLAGS	+= -g
CFLAGS2 = $(CFLAGS) -D ucore_test
CTYPE	:= c S
LD      := $(GCCPREFIX)ld
LDFLAGS	:= -m elf64lriscv
LDFLAGS	+= -nostdlib --gc-sections

OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

COPY	:= cp
MKDIR   := mkdir -p
MV		:= mv
RM		:= rm -f
AWK		:= awk
SED		:= sed
SH		:= sh
TR		:= tr
TOUCH	:= touch -c

OBJDIR	:= obj
BINDIR	:= bin

ALLOBJS	:=
ALLDEPS	:=
TARGETS	:=

include tools/function.mk

listf_cc = $(call listf,$(1),$(CTYPE))

# for cc
add_files_cc = $(call add_files,$(1),$(CC),$(CFLAGS) $(3),$(2),$(4))
add_files_cc2 = $(call add_files,$(1),$(CC),$(CFLAGS2) $(3),$(2),$(4))
create_target_cc = $(call create_target,$(1),$(2),$(3),$(CC),$(CFLAGS))

# for hostcc
add_files_host = $(call add_files,$(1),$(HOSTCC),$(HOSTCFLAGS),$(2),$(3))
create_target_host = $(call create_target,$(1),$(2),$(3),$(HOSTCC),$(HOSTCFLAGS))

cgtype = $(patsubst %.$(2),%.$(3),$(1))
objfile = $(call toobj,$(1))
asmfile = $(call cgtype,$(call toobj,$(1)),o,asm)
outfile = $(call cgtype,$(call toobj,$(1)),o,out)
symfile = $(call cgtype,$(call toobj,$(1)),o,sym)

# for match pattern
match = $(shell echo $(2) | $(AWK) '{for(i=1;i<=NF;i++){if(match("$(1)","^"$$(i)"$$")){exit 1;}}}'; echo $$?)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# include kernel/user

INCLUDE	+= libs/

CFLAGS	+= $(addprefix -I,$(INCLUDE))

LIBDIR	+= libs

$(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)

# -------------------------------------------------------------------
# kernel

KINCLUDE	+= kern/debug/ \
			   kern/driver/ \
			   kern/mm/ \
			   kern/arch/

KSRCDIR		+= kern/init \
			   kern/libs \
			   kern/debug \
			   kern/driver \
			   kern/mm

KCFLAGS		+= $(addprefix -I,$(KINCLUDE))

ifeq ($(MAKECMDGOALS),test)
$(call add_files_cc2,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))
else
$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))
endif
KOBJS	= $(call read_packet,kernel libs)

# create kernel target
kernel = $(call totarget,kernel)

$(kernel): tools/kernel.ld

$(kernel): $(KOBJS)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
	@$(OBJDUMP) -S $@ > $(call asmfile,kernel)
	@$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)

$(call create_target,kernel)

# -------------------------------------------------------------------
# create ucore.img
UCOREIMG	:= $(call totarget,ucore.img)


$(UCOREIMG): $(kernel)
	$(OBJCOPY) $(kernel) --strip-all -O binary $@

$(call create_target,ucore.img)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$(call finish_all)

IGNORE_ALLDEPS	= clean \
				  dist-clean \
				  grade \
				  touch \
				  print-.+ \
				  handin

ifeq ($(call match,$(MAKECMDGOALS),$(IGNORE_ALLDEPS)),0)
-include $(ALLDEPS)
endif

# files for grade script

TARGETS: $(TARGETS)

.DEFAULT_GOAL := TARGETS
.PHONY: qemu spike test
qemu: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) \
		-machine virt \
		-nographic \
		-bios default \
		-device loader,file=$(UCOREIMG),addr=0x80200000

debug: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) \
		-machine virt \
		-nographic \
		-bios default \
		-device loader,file=$(UCOREIMG),addr=0x80200000\
		-s -S

# ============================================================================
# GDB调试目标配置
# ============================================================================
# 用法说明:
#   make gdb          - 连接到QEMU GDB stub (端口1234) 调试ucore内核
#   make gdbserver    - 启动本地GDB调试QEMU源码
#   make gdb-port-5678 - 连接到指定端口调试ucore (例如端口5678)
#
# gdbserver调试流程:
#   1. 终端1: gdbserver localhost:12345 /path/to/qemu ... -s -S
#   2. 终端2: make gdbserver  (连接12345端口调试QEMU源码)
#   3. 终端3: make gdb       (连接1234端口调试ucore内核)

# gdbserver mode - 调试QEMU源码用
gdbserver:
	gdb \
    -ex 'file /defaultShare/archive/yinbowen/Houjd/study/qemu-4.1.1/riscv64-softmmu/qemu-system-riscv64' \
    -ex 'target remote localhost:12345' \
    -ex 'break get_physical_address if addr == 0xffffffffc0204000' \
    -ex 'handle SIGPIPE nostop noprint'

# 启动gdbserver后台进程
debug-start:
	@echo "=== 启动gdbserver ==="
	@gdbserver localhost:12345 $(QEMU) -machine virt -nographic -bios default -device loader,file=$(UCOREIMG),addr=0x80200000 -s -S &
	@echo "等待QEMU初始化..."
	@sleep 5
	@echo "检查gdbserver端口..."
	@until netstat -tlnp | grep -q ":12345.*gdbserver"; do sleep 1; done
	@echo "gdbserver启动成功，监听端口12345"
	@echo "等待QEMU GDB stub开放..."
	@sleep 15
	@echo "检查QEMU GDB stub端口..."
	@until netstat -tlnp | grep -q ":1234.*qemu-system"; do sleep 1; done
	@echo "QEMU GDB stub开放，端口1234"
	@echo "现在可以在终端2运行: make debug-qemu"
	@echo "然后在终端3运行: make debug-ucore"

# QEMU GDB会话 - 设置页表翻译断点
debug-qemu:
	@echo "=== 启动QEMU GDB (观察页表翻译) ==="
	@echo "注意: GDB会保持运行状态，请手动输入 continue 让QEMU继续运行"
	gdb $(QEMU) \
    -ex 'target remote localhost:12345' \
    -ex 'break get_physical_address' \
    -ex 'handle SIGPIPE nostop noprint'

# RISC-V GDB会话 - 触发页表翻译
debug-ucore:
	@echo "=== 启动RISC-V GDB (触发页表翻译) ==="
	@echo "确保QEMU GDB stub (端口1234) 已经开放..."
	@netstat -tlnp | grep -q ":1234.*qemu-system" || (echo "错误: QEMU GDB stub未开放，请先运行终端1的make debug-start"; exit 1)
	riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:1234' \
    -ex 'break pmm_init' \
    -ex 'echo === RISC-V GDB连接成功 ===' \
    -ex 'echo 现在输入 continue 开始ucore执行' \
    -ex 'echo 当看到 satp virtual address: 0xffffffffc0204000 时' \
    -ex 'echo 终端2的QEMU GDB会触发页表翻译断点'

# 最终测试 - 确认页表翻译断点可以触发
debug-final:
	@echo "=== 最终确认：页表翻译断点可以触发 ==="
	@gdbserver localhost:12345 $(QEMU) -machine virt -nographic -bios default -device loader,file=$(UCOREIMG),addr=0x80200000 -s -S &
	@sleep 3
	@echo "启动QEMU GDB，设置断点并自动continue..."
	@gdb $(QEMU) \
	  -ex 'target remote localhost:12345' \
	  -ex 'break get_physical_address' \
	  -ex 'handle SIGPIPE nostop noprint' \
	  -ex 'commands 1' \
	  -ex 'printf "页表翻译断点触发！地址=0x%lx\n", addr' \
	  -ex 'bt 3' \
	  -ex 'continue' \
	  -ex 'end' \
	  -ex 'continue' &
	@sleep 15
	@echo "启动RISC-V GDB触发页表翻译..."
	@riscv64-unknown-elf-gdb \
	  -ex 'file bin/kernel' \
	  -ex 'set arch riscv:rv64' \
	  -ex 'target remote localhost:1234' \
	  -ex 'break pmm_init' \
	  -ex 'continue' 2>&1 | grep -E "(satp virtual address|页表翻译断点)" | head -5

# 完整调试指导
debug-guide:
	@echo "========================================"
	@echo "  页表翻译调试完整指南"
	@echo "========================================"
	@echo ""
	@echo "⚠️ 重要：严格按时序执行，每个步骤都要等待完成！"
	@echo ""
	@echo "步骤1 - 终端1 (启动gdbserver):"
	@echo "  make debug-start"
	@echo "  等待: 'QEMU GDB stub开放，端口1234'"
	@echo ""
	@echo "步骤2 - 终端2 (QEMU GDB):"
	@echo "  make debug-qemu"
	@echo "  在GDB提示符下输入: continue"
	@echo "  等待: 看到大量库加载消息"
	@echo ""
	@echo "步骤3 - 终端3 (RISC-V GDB):"
	@echo "  make debug-ucore"
	@echo "  在GDB提示符下输入: continue"
	@echo "  等待: 'satp virtual address: 0xffffffffc0204000'"
	@echo ""
	@echo "关键观察点："
	@echo "- 终端3显示 'satp virtual address: 0xffffffffc0204000' 时"
	@echo "- 终端2应该立即触发 get_physical_address 断点"
	@echo "- 断点触发时检查: printf \"地址: 0x%lx\\n\", addr"
	@echo ""
	@echo "========================================"

# 重置调试环境
debug-reset:
	@echo "=== 重置调试环境 ==="
	-pkill -f gdbserver
	-pkill -f gdb
	-pkill -f riscv64
	-pkill -f qemu-system
	@echo "所有调试进程已清理"

# ucore mode - 调试ucore内核用 (默认1234端口)
gdb:
	riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:1234'

# 自定义端口版本 - make gdb-port-端口号
gdb-port-%:
	riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:$*'

# 触发页表翻译断点 - 在RISC-V GDB中设置断点并continue
gdb-trigger:
	riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:1234' \
    -ex 'break pmm_init' \
    -ex 'continue'

test: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) \
		-machine virt \
		-nographic \
		-bios default \
		-device loader,file=$(UCOREIMG),addr=0x80200000
spike: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(SPIKE) $(UCOREIMG)

.PHONY: grade touch

GRADE_GDB_IN	:= .gdb.in
GRADE_QEMU_OUT	:= .qemu.out
HANDIN			:= proj$(PROJ)-handin.tar.gz

TOUCH_FILES		:=

MAKEOPTS		:= --quiet --no-print-directory

grade:
	$(V)$(MAKE) $(MAKEOPTS) clean
	$(V)$(SH) tools/grade.sh

touch:
	$(V)$(foreach f,$(TOUCH_FILES),$(TOUCH) $(f))

print-%:
	@echo $($(shell echo $(patsubst print-%,%,$@) | $(TR) [a-z] [A-Z]))

.PHONY: clean dist-clean handin packall tags
clean:
	$(V)$(RM) $(GRADE_GDB_IN) $(GRADE_QEMU_OUT) cscope* tags
	-$(RM) -r $(OBJDIR) $(BINDIR)

dist-clean: clean
	-$(RM) $(HANDIN)

handin: packall
	@echo Please visit http://learn.tsinghua.edu.cn and upload $(HANDIN). Thanks!

packall: clean
	@$(RM) -f $(HANDIN)
	@tar -czf $(HANDIN) `find . -type f -o -type d | grep -v '^\.*$$' | grep -vF '$(HANDIN)'`

tags:
	@echo TAGS ALL
	$(V)rm -f cscope.files cscope.in.out cscope.out cscope.po.out tags
	$(V)find . -type f -name "*.[chS]" >cscope.files
	$(V)cscope -bq 
	$(V)ctags -L cscope.files
