GNU ld (GNU Binutils) 2.38
  Supported emulations:
   i386pe
using internal linker script:
==================================================
/* Default linker script, for normal executables */
/* Copyright (C) 2014-2022 Free Software Foundation, Inc.
   Copying and distribution of this script, with or without modification,
   are permitted in any medium without royalty provided the copyright
   notice and this notice are preserved.  */
OUTPUT_FORMAT(pei-i386)
SEARCH_DIR("=/mingw32/i686-w64-mingw32/lib"); SEARCH_DIR("=/mingw32/lib"); SEARCH_DIR("=/usr/local/lib"); SEARCH_DIR("=/lib"); SEARCH_DIR("=/usr/lib");
SECTIONS
{
  /* Make the virtual address and file offset synced if the alignment is
     lower than the target page size. */
  . = SIZEOF_HEADERS;
  . = ALIGN(__section_alignment__);
  .text  __image_base__ + ( __section_alignment__ < 0x1000 ? . : __section_alignment__ ) :
  {
    KEEP (*(SORT_NONE(.init)))
    *(.text)
    *(SORT(.text$*))
     *(.text.*)
     *(.gnu.linkonce.t.*)
    *(.glue_7t)
    *(.glue_7)
       /* Note: we always define __CTOR_LIST__ and ___CTOR_LIST__ here,
          we do not PROVIDE them.  This is because the ctors.o startup
	  code in libgcc defines them as common symbols, with the
          expectation that they will be overridden by the definitions
	  here.  If we PROVIDE the symbols then they will not be
	  overridden and global constructors will not be run.
	  See PR 22762 for more details.
	  This does mean that it is not possible for a user to define
	  their own __CTOR_LIST__ and __DTOR_LIST__ symbols; if they do,
	  the content from those variables are included but the symbols
	  defined here silently take precedence.  If they truly need to
	  be redefined, a custom linker script will have to be used.
	  (The custom script can just be a copy of this script with the
	  PROVIDE() qualifiers added).
	  In particular this means that ld -Ur does not work, because
	  the proper __CTOR_LIST__ set by ld -Ur is overridden by a
	  bogus __CTOR_LIST__ set by the final link.  See PR 46.  */
       ___CTOR_LIST__ = .;
       __CTOR_LIST__ = .;
       LONG (-1);
       KEEP(*(.ctors));
       KEEP(*(.ctor));
       KEEP(*(SORT_BY_NAME(.ctors.*)));
       LONG (0);
       /* See comment about __CTOR_LIST__ above.  The same reasoning
          applies here too.  */
       ___DTOR_LIST__ = .;
       __DTOR_LIST__ = .;
       LONG (-1);
       KEEP(*(.dtors));
       KEEP(*(.dtor));
       KEEP(*(SORT_BY_NAME(.dtors.*)));
       LONG (0);
    KEEP (*(SORT_NONE(.fini)))
    /* ??? Why is .gcc_exc here?  */
     *(.gcc_exc)
    PROVIDE (etext = .);
    PROVIDE (_etext = .);
     KEEP (*(.gcc_except_table))
  }
  /* The Cygwin32 library uses a section to avoid copying certain data
     on fork.  This used to be named ".data".  The linker used
     to include this between __data_start__ and __data_end__, but that
     breaks building the cygwin32 dll.  Instead, we name the section
     ".data_cygwin_nocopy" and explicitly include it after __data_end__. */
  .data BLOCK(__section_alignment__) :
  {
    __data_start__ = . ;
    *(.data)
    *(.data2)
    *(SORT(.data$*))
    KEEP(*(.jcr))
    __data_end__ = . ;
    *(.data_cygwin_nocopy)
  }
  .rdata BLOCK(__section_alignment__) :
  {
    *(.rdata)
	     *(SORT(.rdata$*))
    . = ALIGN(4);
    __rt_psrelocs_start = .;
    KEEP(*(.rdata_runtime_pseudo_reloc))
    __rt_psrelocs_end = .;
  }
  __rt_psrelocs_size = __rt_psrelocs_end - __rt_psrelocs_start;
  ___RUNTIME_PSEUDO_RELOC_LIST_END__ = .;
  __RUNTIME_PSEUDO_RELOC_LIST_END__ = .;
  ___RUNTIME_PSEUDO_RELOC_LIST__ = . - __rt_psrelocs_size;
  __RUNTIME_PSEUDO_RELOC_LIST__ = . - __rt_psrelocs_size;
  .eh_frame BLOCK(__section_alignment__) :
  {
    KEEP(*(.eh_frame*))
  }
  .pdata BLOCK(__section_alignment__) :
  {
    KEEP(*(.pdata*))
  }
  .bss BLOCK(__section_alignment__) :
  {
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
    __bss_end__ = . ;
  }
  .edata BLOCK(__section_alignment__) :
  {
    *(.edata)
  }
  /DISCARD/ :
  {
    *(.debug$S)
    *(.debug$T)
    *(.debug$F)
    *(.drectve)
     *(.note.GNU-stack)
     *(.gnu.lto_*)
  }
  .idata BLOCK(__section_alignment__) :
  {
    /* This cannot currently be handled with grouped sections.
	See pe.em:sort_sections.  */
    KEEP (SORT(*)(.idata$2))
    KEEP (SORT(*)(.idata$3))
    /* These zeroes mark the end of the import list.  */
    LONG (0); LONG (0); LONG (0); LONG (0); LONG (0);
    KEEP (SORT(*)(.idata$4))
    __IAT_start__ = .;
    KEEP (SORT(*)(.idata$5))
    __IAT_end__ = .;
    KEEP (SORT(*)(.idata$6))
    KEEP (SORT(*)(.idata$7))
  }
  .CRT BLOCK(__section_alignment__) :
  {
    ___crt_xc_start__ = . ;
    KEEP (*(SORT(.CRT$XC*)))  /* C initialization */
    ___crt_xc_end__ = . ;
    ___crt_xi_start__ = . ;
    KEEP (*(SORT(.CRT$XI*)))  /* C++ initialization */
    ___crt_xi_end__ = . ;
    ___crt_xl_start__ = . ;
    KEEP (*(SORT(.CRT$XL*)))  /* TLS callbacks */
    /* ___crt_xl_end__ is defined in the TLS Directory support code */
    ___crt_xp_start__ = . ;
    KEEP (*(SORT(.CRT$XP*)))  /* Pre-termination */
    ___crt_xp_end__ = . ;
    ___crt_xt_start__ = . ;
    KEEP (*(SORT(.CRT$XT*)))  /* Termination */
    ___crt_xt_end__ = . ;
  }
  /* Windows TLS expects .tls$AAA to be at the start and .tls$ZZZ to be
     at the end of section.  This is important because _tls_start MUST
     be at the beginning of the section to enable SECREL32 relocations with TLS
     data.  */
  .tls BLOCK(__section_alignment__) :
  {
    ___tls_start__ = . ;
    KEEP (*(.tls$AAA))
    KEEP (*(.tls))
    KEEP (*(.tls$))
    KEEP (*(SORT(.tls$*)))
    KEEP (*(.tls$ZZZ))
    ___tls_end__ = . ;
  }
  .endjunk BLOCK(__section_alignment__) :
  {
    /* end is deprecated, don't use it */
    PROVIDE (end = .);
    PROVIDE ( _end = .);
     __end__ = .;
  }
  .rsrc BLOCK(__section_alignment__) : SUBALIGN(4)
  {
    KEEP (*(.rsrc))
    KEEP (*(.rsrc$*))
  }
  .reloc BLOCK(__section_alignment__) :
  {
    *(.reloc)
  }
  .stab BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.stab)
  }
  .stabstr BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.stabstr)
  }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section.  Unlike other targets that fake this by putting the
     section VMA at 0, the PE format will not allow it.  */
  /* DWARF 1.1 and DWARF 2.  */
  .debug_aranges BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_aranges)
  }
  .zdebug_aranges BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_aranges)
  }
  .debug_pubnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_pubnames)
  }
  .zdebug_pubnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_pubnames)
  }
  /* DWARF 2.  */
  .debug_info BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_info .gnu.linkonce.wi.*)
  }
  .zdebug_info BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_info .zdebug.gnu.linkonce.wi.*)
  }
  .debug_abbrev BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_abbrev)
  }
  .zdebug_abbrev BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_abbrev)
  }
  .debug_line BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_line)
  }
  .zdebug_line BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_line)
  }
  .debug_frame BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_frame*)
  }
  .zdebug_frame BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_frame*)
  }
  .debug_str BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_str)
  }
  .zdebug_str BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_str)
  }
  .debug_loc BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_loc)
  }
  .zdebug_loc BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_loc)
  }
  .debug_macinfo BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_macinfo)
  }
  .zdebug_macinfo BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_macinfo)
  }
  /* SGI/MIPS DWARF 2 extensions.  */
  .debug_weaknames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_weaknames)
  }
  .zdebug_weaknames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_weaknames)
  }
  .debug_funcnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_funcnames)
  }
  .zdebug_funcnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_funcnames)
  }
  .debug_typenames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_typenames)
  }
  .zdebug_typenames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_typenames)
  }
  .debug_varnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_varnames)
  }
  .zdebug_varnames BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_varnames)
  }
  /* DWARF 3.  */
  .debug_pubtypes BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_pubtypes)
  }
  .zdebug_pubtypes BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_pubtypes)
  }
  .debug_ranges BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_ranges)
  }
  .zdebug_ranges BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_ranges)
  }
  /* DWARF 4.  */
  .debug_types BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_types .gnu.linkonce.wt.*)
  }
  .zdebug_types BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_types .gnu.linkonce.wt.*)
  }
  /* DWARF 5.  */
  .debug_addr BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_addr)
  }
  .zdebug_addr BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_addr)
  }
  .debug_line_str BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_line_str)
  }
  .zdebug_line_str BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_line_str)
  }
  .debug_loclists BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_loclists)
  }
  .zdebug_loclists BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_loclists)
  }
  .debug_macro BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_macro)
  }
  .zdebug_macro BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_macro)
  }
  .debug_names BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_names)
  }
  .zdebug_names BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_names)
  }
  .debug_rnglists BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_rnglists)
  }
  .zdebug_rnglists BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_rnglists)
  }
  .debug_str_offsets BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_str_offsets)
  }
  .zdebug_str_offsets BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_str_offsets)
  }
  .debug_sup BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_sup)
  }
  /* For Go and Rust.  */
  .debug_gdb_scripts BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.debug_gdb_scripts)
  }
  .zdebug_gdb_scripts BLOCK(__section_alignment__) (NOLOAD) :
  {
    *(.zdebug_gdb_scripts)
  }
}


==================================================
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/bin/ld.exe: mode i386pe
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/crt2.o succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/crt2.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/crtbegin.o succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/crtbegin.o
attempt to open objs/nginx_wpd_ics_opt.o succeeded
objs/nginx_wpd_ics_opt.o
attempt to open C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib succeeded
C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
(C:/Users/rudy/h/wo/decker/whole-program-debloat/build/debloat_rt/Release/debloat_rt.lib)debloat_rt.dll
attempt to open C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib succeeded
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/kernel32.lib)KERNEL32.dll
attempt to open C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/user32.lib succeeded
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/user32.lib
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/user32.lib)USER32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/user32.lib)USER32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/user32.lib)USER32.dll
attempt to open C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib succeeded
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/advapi32.lib)ADVAPI32.dll
attempt to open C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib succeeded
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
(C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x86/ws2_32.lib)WS2_32.dll
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-gccmain.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-natstart.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-wildcard.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-dllargv.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-_newmode.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-tlssup.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-xncommod.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-cinitexe.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-merr.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-CRT_fp10.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-mingw_helpers.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-pseudo-reloc.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-usermatherr.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-xtxtmode.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-crt_handler.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-tlsthrd.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-tlsmcrt.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-pseudo-reloc-list.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a)lib32_libmingw32_a-pesect.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/gcc.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_chkstk.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_chkstk_ms.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_ctors.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_divdi3.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_udivdi3.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a)_umoddi3.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/gcc_eh.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.a
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.a)lib32_libmingwex_a-mingw_matherr.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)lib32_libmsvcrt_extra_a-invalid_parameter_handler.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)lib32_libmsvcrt_common_a-acrt_iob_func.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00057.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00058.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00076.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00078.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00083.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00104.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00107.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00144.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00161.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00218.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00353.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00357.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00631.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs00912.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01059.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01073.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01086.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01103.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01110.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01123.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01129.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01130.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01162.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01170.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01179.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01180.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01181.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01182.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01183.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01194.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01197.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01199.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01209.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01214.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01220.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01221.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01227.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01228.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01231.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01234.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01237.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01262.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defs01269.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_defh.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a)libmsvcrt_deft.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s01471.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s01468.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s01420.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s00972.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s00876.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s00309.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32s00276.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32h.o
(C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a)libkernel32t.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libpthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/pthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/pthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libpthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libpthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/pthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libpthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/pthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/pthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libpthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libpthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/pthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libpthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/pthread.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/pthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libpthread.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libpthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/pthread.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libpthread.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libpthread.dll.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libpthread.dll.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libadvapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/advapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/advapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libadvapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libadvapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/advapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libadvapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/advapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/advapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libadvapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libadvapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/advapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libadvapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/advapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/advapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libadvapi32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libadvapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/advapi32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libadvapi32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libadvapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/advapi32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libadvapi32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libadvapi32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libshell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/shell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/shell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libshell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libshell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/shell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libshell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/shell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/shell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libshell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libshell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/shell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libshell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/shell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/shell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libshell32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libshell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/shell32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libshell32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libshell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/shell32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libshell32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libshell32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libuser32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/user32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/user32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libuser32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libuser32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/user32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libuser32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/user32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/user32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libuser32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libuser32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/user32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libuser32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/user32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/user32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libuser32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libuser32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/user32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libuser32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libuser32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/user32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libuser32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libuser32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingw32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmingw32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/mingw32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingw32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/gcc.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/gcc_eh.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libgcc_eh.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmoldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/moldname.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmoldname.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/moldname.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmoldname.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/mingwex.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmingwex.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/mingwex.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmingwex.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libmsvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/msvcrt.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libmsvcrt.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/msvcrt.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libmsvcrt.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.lib failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/libkernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib/kernel32.dll failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../i686-w64-mingw32/lib/../lib\libkernel32.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/kernel32.dll.a failed
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/libkernel32.a
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/default-manifest.o succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/../../../../lib/default-manifest.o
attempt to open C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/crtend.o succeeded
C:/msys64/mingw32/bin/../lib/gcc/i686-w64-mingw32/11.2.0/crtend.o
