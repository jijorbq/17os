cmake_minimum_required(VERSION 3.0)
project(BOOT)



#指定可以使用nasm编译
enable_language(ASM_NASM)
set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS asm)
set(CMAKE_ASM_NASM_OBJECT_FORMAT bin)
set(CMAKE_ASM_NASM_COMPILE_OBJECT "nasm <INCLUDES> <FLAGS> -f bin -o <OBJECT> <SOURCE>")
set(CMAKE_ASM_NASM_LINK_EXECUTABLE "cp <OBJECTS>  <TARGET>")
add_executable(boot boot.asm)

#将编译产生的bin文件复制到a.img中
add_custom_command(
        OUTPUT ${PROJECT_BINARY_DIR}/a.img
        DEPENDS boot
        COMMAND cp ${PROJECT_SOURCE_DIR}/a.img  ${PROJECT_BINARY_DIR}/a.img
        COMMAND dd if=boot of=a.img conv=notrunc)

add_custom_target(
        DEBUG ALL
        DEPENDS ${PROJECT_BINARY_DIR}/a.img
        COMMAND cp ${PROJECT_SOURCE_DIR}/bochsrc ${PROJECT_BINARY_DIR}/bochsrc
        COMMAND bochs-disasm -q -f bochsrc)
