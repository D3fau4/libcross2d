# setup toolchains

if (PLATFORM_LINUX)
    set(CMAKE_SYSTEM_NAME "Linux")
    set(TARGET_PLATFORM linux CACHE STRING "")
endif ()
if (PLATFORM_RPI3)
    set(CMAKE_SYSTEM_NAME Generic)
    set(PLATFORM_LINUX ON CACHE BOOL "" FORCE)
    if (OPTION_RECALBOX_BUILDROOT)
        set(CMAKE_SYSTEM_PROCESSOR "armv7")
        set(ARCH arm)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__RPI3__" CACHE STRING "C flags")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__RPI3__" CACHE STRING "C flags")
        set(ENV{PKG_CONFIG_DIR} "")
        set(ENV{PKG_CONFIG_LIBDIR} "${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig")
        set(ENV{PKG_CONFIG_SYSROOT_DIR} ${SYSROOT})
        set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not wanted")
        set(TARGET_PLATFORM rpi3 CACHE STRING "" FORCE)
    else ()
        if (${X64})
            set(CMAKE_SYSTEM_PROCESSOR "aarch64")
            set(ARCH aarch64)
            set(RPI3_SDK /opt/buildroot/buildroot-2019.02.3/output/host)
            set(RPI3_SYS ${RPI3_SDK}/aarch64-buildroot-linux-gnu/sysroot)
            set(TARGET_PLATFORM rpi3-x64 CACHE STRING "" FORCE)
        else ()
            set(CMAKE_SYSTEM_PROCESSOR "armv7")
            set(ARCH arm)
            set(RPI3_SDK /opt/recalbox/output/host)
            set(RPI3_SYS ${RPI3_SDK}/arm-buildroot-linux-gnueabihf/sysroot)
            set(TARGET_PLATFORM rpi3 CACHE STRING "" FORCE)
        endif ()
        set(CMAKE_C_COMPILER "${RPI3_SDK}/bin/${ARCH}-linux-gcc")
        set(CMAKE_CXX_COMPILER "${RPI3_SDK}/bin/${ARCH}-linux-g++")
        set(CMAKE_ASM_COMPILER "${RPI3_SDK}/bin/${ARCH}-linux-as")
        set(CMAKE_AR "${RPI3_SDK}/bin/${ARCH}-linux-ar")
        set(CMAKE_RANLIB "${RPI3_SDK}/bin/${ARCH}-linux-ranlib")
        set(CMAKE_C_FLAGS "-D__RPI3__ -I${RPI3_SYS}/include -I${RPI3_SYS}/usr/include" CACHE STRING "C flags")
        set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive -std=gnu++1z" CACHE STRING "C++ flags")
        set(ENV{PKG_CONFIG_DIR} "")
        set(ENV{PKG_CONFIG_LIBDIR} "${RPI3_SYS}/usr/lib/pkgconfig:${RPI3_SYS}/usr/share/pkgconfig")
        set(ENV{PKG_CONFIG_SYSROOT_DIR} ${RPI3_SYS})
        set(CMAKE_FIND_ROOT_PATH ${RPI3_SYS} ${RPI3_SYS}/usr)
        set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
        set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
        set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
        set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
        set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not wanted")
    endif ()
endif ()
if (PLATFORM_LDK)
    set(PLATFORM_LINUX ON)
    set(CMAKE_SYSTEM_NAME "Linux")
    set(MIPS_SDK /opt/buildroot/buildroot-2019.02.3/output/host)
    set(MIPS_SYS ${MIPS_SDK}/mipsel-buildroot-linux-uclibc/sysroot)
    set(CMAKE_SYSTEM_PROCESSOR "mips")
    set(CMAKE_C_COMPILER "${MIPS_SDK}/bin/mipsel-linux-gcc")
    set(CMAKE_CXX_COMPILER "${MIPS_SDK}/bin/mipsel-linux-g++")
    set(CMAKE_ASM_COMPILER "${MIPS_SDK}/bin/mipsel-linux-as")
    set(CMAKE_AR "${MIPS_SDK}/bin/mipsel-linux-ar" CACHE STRING "")
    set(CMAKE_RANLIB "${MIPS_SDK}/bin/mipsel-linux-gcc-ranlib" CACHE STRING "")
    set(CMAKE_C_FLAGS "-D__LDK__ -I${MIPS_SYS}/include -I${MIPS_SYS}/usr/include" CACHE STRING "C flags")
    set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive" CACHE STRING "C++ flags")
    set(ENV{PKG_CONFIG_DIR} "")
    set(ENV{PKG_CONFIG_LIBDIR} "${MIPS_SYS}/usr/lib/pkgconfig:${MIPS_SYS}/usr/share/pkgconfig")
    set(ENV{PKG_CONFIG_SYSROOT_DIR} ${MIPS_SYS})
    set(CMAKE_FIND_ROOT_PATH ${MIPS_SYS} ${MIPS_SYS}/usr)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
    set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not wanted")
    set(TARGET_PLATFORM mips CACHE STRING "" FORCE)
endif ()
if (PLATFORM_WINDOWS)
    set(PLATFORM_LINUX ON)
    set(TARGET_PLATFORM windows CACHE STRING "" FORCE)
elseif (PLATFORM_SWITCH)
    message(FATAL_ERROR TODO: fix switch toolchain)
    set(DEVKITPRO $ENV{DEVKITPRO} CACHE BOOL "DEVKITPRO")
    include(${DEVKITPRO}/switch.cmake)
    #set(CMAKE_SYSTEM_NAME "Generic")
    #set(CMAKE_SYSTEM_PROCESSOR aarch64)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${DEVKITPRO}/libnx/lib -L${DEVKITPRO}/portlibs/switch/lib" CACHE STRING "Linker flags")
    set(CMAKE_C_COMPILER "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-gcc")
    set(CMAKE_CXX_COMPILER "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-g++")
    set(CMAKE_ASM_COMPILER "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-as")
    set(CMAKE_AR "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-gcc-ar")
    set(CMAKE_RANLIB "${DEVKITPRO}/devkitA64/bin/aarch64-none-elf-gcc-ranlib")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${DEVKITPRO}/libnx/include -I${DEVKITPRO}/portlibs/switch/include" CACHE STRING "C flags")
    set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive" CACHE STRING "C++ flags")
    set(ENV{PKG_CONFIG_DIR} "")
    set(ENV{PKG_CONFIG_LIBDIR} "${DEVKITPRO}/portlibs/switch/lib/pkgconfig")
    set(ENV{PKG_CONFIG_SYSROOT_DIR} "")
    set(CMAKE_FIND_ROOT_PATH ${DEVKITPRO}/libnx ${DEVKITPRO}/portlibs/switch)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
    set(TARGET_PLATFORM switch CACHE STRING "")
    set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not wanted")
elseif (PLATFORM_VITA)
    set(CMAKE_SYSTEM_NAME "Generic")
    if (DEFINED ENV{VITASDK})
        include("$ENV{VITASDK}/share/vita.toolchain.cmake")
    else ()
        message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
    endif ()
    include("$ENV{VITASDK}/share/vita.cmake" REQUIRED)
    set(TARGET_PLATFORM vita CACHE STRING "")
elseif (PLATFORM_3DS)
    set(DEVKITPRO $ENV{DEVKITPRO} CACHE BOOL "DEVKITPRO")
    include(${DEVKITPRO}/3ds.cmake)
    set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS_INIT} CACHE STRING "" FORCE)
    set(CMAKE_C_COMPILER "${DEVKITPRO}/devkitARM/bin/arm-none-eabi-gcc")
    set(CMAKE_CXX_COMPILER "${DEVKITPRO}/devkitARM/bin/arm-none-eabi-g++")
    set(CMAKE_ASM_COMPILER "${DEVKITPRO}/devkitARM/bin/arm-none-eabi-as")
    set(CMAKE_AR "${DEVKITPRO}/devkitARM/bin/arm-none-eabi-ar")
    set(CMAKE_RANLIB "${DEVKITPRO}/devkitARM/bin/arm-none-eabi-gcc-ranlib")
    set(CMAKE_C_FLAGS "-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -O2 -mword-relocations -ffunction-sections -fdata-sections -I${DEVKITPRO}/libctru/include -I${DEVKITPRO}/portlibs/3ds/include" CACHE STRING "C flags")
    set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive" CACHE STRING "C++ flags")
    set(CMAKE_FIND_ROOT_PATH ${DEVKITPRO}/libctru ${DEVKITPRO}/portlibs/3ds)
    set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT} -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -L${DEVKITPRO}/portlibs/3ds/lib -L${DEVKITPRO}/libctru/lib")
    set(TARGET_PLATFORM 3ds CACHE STRING "")
endif ()

message(STATUS "C2D: cmake version: ${CMAKE_VERSION}")
message(STATUS "C2D: Target platform: ${TARGET_PLATFORM}")
