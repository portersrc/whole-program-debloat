/* Script for -pie -z combreloc -z now -z relro: position independent executable, combine & sort relocs */
/* Copyright (C) 2014-2018 Free Software Foundation, Inc.
Copying and distribution of this script, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  */
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64",
"elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)
SEARCH_DIR("=/usr/local/lib/x86_64-linux-gnu"); SEARCH_DIR("=/lib/x86_64-linux-gnu"); SEARCH_DIR("=/usr/lib/x86_64-linux-gnu"); SEARCH_DIR("=/usr/lib/x86_64-linux-gnu64"); SEARCH_DIR("=/usr/local/lib64"); SEARCH_DIR("=/lib64"); SEARCH_DIR("=/usr/lib64"); SEARCH_DIR("=/usr/local/lib"); SEARCH_DIR("=/lib"); SEARCH_DIR("=/usr/lib"); SEARCH_DIR("=/usr/x86_64-linux-gnu/lib64"); SEARCH_DIR("=/usr/x86_64-linux-gnu/lib");
SECTIONS
{
/* Read-only sections, merged into text segment: */
PROVIDE (__executable_start = SEGMENT_START("text-segment", 0)); . = SEGMENT_START("text-segment", 0) + SIZEOF_HEADERS;
.interp         : { *(.interp) }
.note.gnu.build-id : { *(.note.gnu.build-id) }
.hash           : { *(.hash) }
.gnu.hash       : { *(.gnu.hash) }
.dynsym         : { *(.dynsym) }
.dynstr         : { *(.dynstr) }
.gnu.version    : { *(.gnu.version) }
.gnu.version_d  : { *(.gnu.version_d) }
.gnu.version_r  : { *(.gnu.version_r) }
.rela.dyn       :
{
*(.rela.init)
*(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
*(.rela.fini)
*(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
*(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
*(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
*(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
*(.rela.ctors)
*(.rela.dtors)
*(.rela.got)
*(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
*(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
*(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
*(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
*(.rela.ifunc)
}
.rela.plt       :
{
*(.rela.plt)
PROVIDE_HIDDEN (__rela_iplt_start = .);
*(.rela.iplt)
PROVIDE_HIDDEN (__rela_iplt_end = .);
}
.init           :
{
KEEP (*(SORT_NONE(.init)))
}
.plt            : { *(.plt) *(.iplt) }
.plt.got        : { *(.plt.got) }
.plt.sec        : { *(.plt.sec) }
.text ALIGN(0x1000):
{
*(.text.unlikely .text.*_unlikely .text.unlikely.*)
*(.text.exit .text.exit.*)
*(.text.startup .text.startup.*)
*(.text.hot .text.hot.*)
*(.stub .gnu.linkonce.t.*)
*(.text)
. = ALIGN(0x1000);
*(.text.Perl_lex_stuff_pvn)
. = ALIGN(0x1000);
*(.text.Perl_dump_packsubs_perl .text.Perl_dump_form)
. = ALIGN(0x1000);
*(.text.Perl_dump_sub_perl)
. = ALIGN(0x1000);
*(.text.PerlIO_cleantable)
. = ALIGN(0x1000);
*(.text.PerlIO_exportFILE)
. = ALIGN(0x1000);
*(.text.perl_construct)
. = ALIGN(0x1000);
*(.text.perl_parse)
. = ALIGN(0x1000);
*(.text.perl_run)
. = ALIGN(0x1000);
*(.text.perl_destruct)
. = ALIGN(0x1000);
*(.text.perl_free)
. = ALIGN(0x1000);
*(.text.Perl_sys_term)
. = ALIGN(0x1000);
*(.text.Perl_cv_set_call_checker_flags)
. = ALIGN(0x1000);
*(.text.Perl_mg_free_type)
. = ALIGN(0x1000);
*(.text.Perl_init_constants)
. = ALIGN(0x1000);
*(.text.PerlIO_destruct)
. = ALIGN(0x1000);
*(.text.Perl_sv_clean_objs)
. = ALIGN(0x1000);
*(.text.PerlIO_cleanup)
. = ALIGN(0x1000);
*(.text.Perl_sv_free_arenas)
. = ALIGN(0x1000);
*(.text.S_init_postdump_symbols)
. = ALIGN(0x1000);
*(.text.Perl_find_script)
. = ALIGN(0x1000);
*(.text.Perl_boot_core_UNIVERSAL)
. = ALIGN(0x1000);
*(.text.Perl_boot_core_mro)
. = ALIGN(0x1000);
*(.text.Perl_gv_check)
. = ALIGN(0x1000);
*(.text.S_run_body)
. = ALIGN(0x1000);
*(.text.Perl_savesharedpvn)
. = ALIGN(0x1000);
*(.text.Perl_sv_catsv_flags)
. = ALIGN(0x1000);
*(.text.Perl_find_runcv_where)
. = ALIGN(0x1000);
*(.text.S_utf16_textfilter)
. = ALIGN(0x1000);
*(.text.Perl_utf16_to_utf8)
. = ALIGN(0x1000);
*(.text.Perl_keyword_plugin_standard)
. = ALIGN(0x1000);
*(.text.XS_UNIVERSAL_isa)
. = ALIGN(0x1000);
*(.text.XS_UNIVERSAL_can)
. = ALIGN(0x1000);
*(.text.XS_UNIVERSAL_DOES)
. = ALIGN(0x1000);
*(.text.Perl_sv_does_sv)
. = ALIGN(0x1000);
*(.text.XS_utf8_is_utf8)
. = ALIGN(0x1000);
*(.text.XS_utf8_valid)
. = ALIGN(0x1000);
*(.text.XS_utf8_encode)
. = ALIGN(0x1000);
*(.text.XS_utf8_decode)
. = ALIGN(0x1000);
*(.text.XS_utf8_upgrade)
. = ALIGN(0x1000);
*(.text.XS_utf8_downgrade)
. = ALIGN(0x1000);
*(.text.XS_utf8_native_to_unicode)
. = ALIGN(0x1000);
*(.text.XS_utf8_unicode_to_native)
. = ALIGN(0x1000);
*(.text.XS_Internals_SvREADONLY)
. = ALIGN(0x1000);
*(.text.XS_constant__make_const)
. = ALIGN(0x1000);
*(.text.XS_Internals_SvREFCNT)
. = ALIGN(0x1000);
*(.text.XS_Internals_hv_clear_placehold)
. = ALIGN(0x1000);
*(.text.XS_PerlIO_get_layers .text.PerlIO_get_layers)
. = ALIGN(0x1000);
*(.text.XS_re_is_regexp)
. = ALIGN(0x1000);
*(.text.XS_re_regnames_count)
. = ALIGN(0x1000);
*(.text.XS_re_regname)
. = ALIGN(0x1000);
*(.text.XS_re_regnames)
. = ALIGN(0x1000);
*(.text.XS_re_regexp_pattern)
. = ALIGN(0x1000);
*(.text.XS_universal_version)
. = ALIGN(0x1000);
*(.text.XS_version_new)
. = ALIGN(0x1000);
*(.text.XS_version_stringify)
. = ALIGN(0x1000);
*(.text.XS_version_numify)
. = ALIGN(0x1000);
*(.text.XS_version_normal)
. = ALIGN(0x1000);
*(.text.XS_version_vcmp)
. = ALIGN(0x1000);
*(.text.XS_version_boolean)
. = ALIGN(0x1000);
*(.text.XS_version_noop)
. = ALIGN(0x1000);
*(.text.XS_version_is_alpha)
. = ALIGN(0x1000);
*(.text.XS_version_qv)
. = ALIGN(0x1000);
*(.text.XS_version_is_qv)
. = ALIGN(0x1000);
*(.text.S_version_check_key)
. = ALIGN(0x1000);
*(.text.optimize_out_native_convert_function)
. = ALIGN(0x1000);
*(.text.S_unwind_scan_frames)
. = ALIGN(0x1000);
*(.text.Perl_regexec_flags .text.S_reg_set_capture_string)
. = ALIGN(0x1000);
*(.text.Perl_re_intuit_start .text.S_regmatch .text.S_to_utf8_substr .text.S_to_byte_substr .text.S_find_byclass .text.S_reginclass .text.S_isGCB .text.S_isSB .text.S_isWB .text.S_isFOO_utf8_lc .text.S_isFOO_lc .text.S_backup_one_WB .text.S_backup_one_SB .text.S_regcppush .text.S_regcppop .text.S_setup_EXACTISH_ST_c1_c2 .text.S_regrepeat)
. = ALIGN(0x1000);
*(.text.S_cleanup_regmatch_info_aux)
. = ALIGN(0x1000);
*(.text.Perl_runops_standard)
. = ALIGN(0x1000);
*(.text.Perl_sv_cmp)
. = ALIGN(0x1000);
*(.text.Perl_debstack .text.Perl_runops_debug .text.Perl_debop .text.S_deb_padvar .text.Perl_multideref_stringify)
. = ALIGN(0x1000);
*(.text.core_xsub)
. = ALIGN(0x1000);
*(.text.Perl_magic_freearylen_p)
. = ALIGN(0x1000);
*(.text.Perl_magic_getpos)
. = ALIGN(0x1000);
*(.text.Perl_magic_setpos)
. = ALIGN(0x1000);
*(.text.Perl_magic_getsubstr)
. = ALIGN(0x1000);
*(.text.Perl_magic_setsubstr)
. = ALIGN(0x1000);
*(.text.Perl_magic_gettaint)
. = ALIGN(0x1000);
*(.text.Perl_magic_settaint)
. = ALIGN(0x1000);
*(.text.Perl_magic_getvec)
. = ALIGN(0x1000);
*(.text.Perl_do_vecset .text.Perl_magic_setvec)
. = ALIGN(0x1000);
*(.text.Perl_magic_freeovrld)
. = ALIGN(0x1000);
*(.text.const_sv_xsub)
. = ALIGN(0x1000);
*(.text.const_av_xsub)
. = ALIGN(0x1000);
*(.text.uvcompare)
. = ALIGN(0x1000);
*(.text.Perl_magic_setutf8)
. = ALIGN(0x1000);
*(.text.Perl_magic_regdata_cnt)
. = ALIGN(0x1000);
*(.text.Perl_magic_regdatum_get)
. = ALIGN(0x1000);
*(.text.Perl_magic_regdatum_set)
. = ALIGN(0x1000);
*(.text.Perl_emulate_cop_io .text.Perl_magic_get)
. = ALIGN(0x1000);
*(.text.Perl_magic_getuvar)
. = ALIGN(0x1000);
*(.text.Perl_magic_setenv)
. = ALIGN(0x1000);
*(.text.Perl_magic_clearenv)
. = ALIGN(0x1000);
*(.text.Perl_magic_set_all_env)
. = ALIGN(0x1000);
*(.text.Perl_magic_clear_all_env)
. = ALIGN(0x1000);
*(.text.Perl_magic_getsig)
. = ALIGN(0x1000);
*(.text.Perl_magic_clearsig)
. = ALIGN(0x1000);
*(.text.Perl_magic_setsig)
. = ALIGN(0x1000);
*(.text.Perl_csighandler)
. = ALIGN(0x1000);
*(.text.Perl_despatch_signals)
. = ALIGN(0x1000);
*(.text.Perl_magic_setisa)
. = ALIGN(0x1000);
*(.text.Perl_magic_getnkeys)
. = ALIGN(0x1000);
*(.text.Perl_magic_setnkeys)
. = ALIGN(0x1000);
*(.text.Perl_magic_getpack)
. = ALIGN(0x1000);
*(.text.Perl_magic_setpack)
. = ALIGN(0x1000);
*(.text.Perl_magic_clearpack)
. = ALIGN(0x1000);
*(.text.Perl_magic_sizepack)
. = ALIGN(0x1000);
*(.text.Perl_magic_wipepack)
. = ALIGN(0x1000);
*(.text.Perl_magic_setdbline)
. = ALIGN(0x1000);
*(.text.Perl_magic_getarylen)
. = ALIGN(0x1000);
*(.text.Perl_magic_setarylen)
. = ALIGN(0x1000);
*(.text.Perl_magic_cleararylen_p)
. = ALIGN(0x1000);
*(.text.Perl_magic_getdefelem)
. = ALIGN(0x1000);
*(.text.Perl_magic_setdefelem)
. = ALIGN(0x1000);
*(.text.Perl_magic_killbackrefs)
. = ALIGN(0x1000);
*(.text.Perl_magic_setmglob)
. = ALIGN(0x1000);
*(.text.Perl_magic_setuvar)
. = ALIGN(0x1000);
*(.text.Perl_magic_setregexp)
. = ALIGN(0x1000);
*(.text.Perl_magic_setlvref)
. = ALIGN(0x1000);
*(.text.Perl_magic_set)
. = ALIGN(0x1000);
*(.text.Perl_sighandler)
. = ALIGN(0x1000);
*(.text.S_unwind_handler_stack)
. = ALIGN(0x1000);
*(.text.Perl_magic_sethint)
. = ALIGN(0x1000);
*(.text.Perl_magic_clearhint)
. = ALIGN(0x1000);
*(.text.Perl_magic_clearhints)
. = ALIGN(0x1000);
*(.text.Perl_magic_copycallchecker)
. = ALIGN(0x1000);
*(.text.Perl_magic_setdebugvar)
. = ALIGN(0x1000);
*(.text.Perl_magic_getdebugvar)
. = ALIGN(0x1000);
*(.text.Perl_ck_ftst)
. = ALIGN(0x1000);
*(.text.xs_init)
. = ALIGN(0x1000);
*(.text.S_clear_yystack)
. = ALIGN(0x1000);
*(.text.Perl_pp_stub)
. = ALIGN(0x1000);
*(.text.Perl_pp_padhv)
. = ALIGN(0x1000);
*(.text.Perl_pp_padcv)
. = ALIGN(0x1000);
*(.text.Perl_pp_introcv)
. = ALIGN(0x1000);
*(.text.Perl_pp_clonecv)
. = ALIGN(0x1000);
*(.text.Perl_pp_rv2gv)
. = ALIGN(0x1000);
*(.text.Perl_pp_rv2sv)
. = ALIGN(0x1000);
*(.text.Perl_pp_bless)
. = ALIGN(0x1000);
*(.text.Perl_pp_gelem)
. = ALIGN(0x1000);
*(.text.Perl_pp_study)
. = ALIGN(0x1000);
*(.text.Perl_do_trans .text.Perl_pp_trans)
. = ALIGN(0x1000);
*(.text.Perl_pp_schop)
. = ALIGN(0x1000);
*(.text.Perl_pp_chop)
. = ALIGN(0x1000);
*(.text.S_do_chomp)
. = ALIGN(0x1000);
*(.text.Perl_pp_undef)
. = ALIGN(0x1000);
*(.text.Perl_pp_postinc)
. = ALIGN(0x1000);
*(.text.Perl_pp_pow)
. = ALIGN(0x1000);
*(.text.Perl_pp_multiply)
. = ALIGN(0x1000);
*(.text.Perl_pp_divide)
. = ALIGN(0x1000);
*(.text.Perl_pp_modulo)
. = ALIGN(0x1000);
*(.text.Perl_pp_repeat)
. = ALIGN(0x1000);
*(.text.Perl_pp_subtract)
. = ALIGN(0x1000);
*(.text.Perl_pp_left_shift)
. = ALIGN(0x1000);
*(.text.Perl_pp_right_shift)
. = ALIGN(0x1000);
*(.text.Perl_pp_lt)
. = ALIGN(0x1000);
*(.text.Perl_pp_gt)
. = ALIGN(0x1000);
*(.text.Perl_pp_le)
. = ALIGN(0x1000);
*(.text.Perl_pp_ge)
. = ALIGN(0x1000);
*(.text.Perl_pp_ne)
. = ALIGN(0x1000);
*(.text.Perl_pp_ncmp)
. = ALIGN(0x1000);
*(.text.Perl_pp_sle)
. = ALIGN(0x1000);
*(.text.Perl_pp_seq)
. = ALIGN(0x1000);
*(.text.Perl_pp_sne)
. = ALIGN(0x1000);
*(.text.Perl_pp_scmp)
. = ALIGN(0x1000);
*(.text.Perl_pp_bit_and)
. = ALIGN(0x1000);
*(.text.Perl_pp_nbit_and)
. = ALIGN(0x1000);
*(.text.Perl_pp_sbit_and)
. = ALIGN(0x1000);
*(.text.Perl_pp_bit_or)
. = ALIGN(0x1000);
*(.text.Perl_pp_nbit_or)
. = ALIGN(0x1000);
*(.text.Perl_pp_sbit_or)
. = ALIGN(0x1000);
*(.text.Perl_do_vop)
. = ALIGN(0x1000);
*(.text.Perl_pp_negate)
. = ALIGN(0x1000);
*(.text.Perl_pp_not)
. = ALIGN(0x1000);
*(.text.Perl_pp_complement)
. = ALIGN(0x1000);
*(.text.Perl_pp_ncomplement)
. = ALIGN(0x1000);
*(.text.Perl_pp_scomplement)
. = ALIGN(0x1000);
*(.text.S_scomplement)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_multiply)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_divide)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_modulo)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_add)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_subtract)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_lt)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_gt)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_le)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_ge)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_eq)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_ne)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_ncmp)
. = ALIGN(0x1000);
*(.text.Perl_pp_i_negate)
. = ALIGN(0x1000);
*(.text.S_negate_string)
. = ALIGN(0x1000);
*(.text.Perl_pp_atan2)
. = ALIGN(0x1000);
*(.text.Perl_pp_sin)
. = ALIGN(0x1000);
*(.text.Perl_pp_rand)
. = ALIGN(0x1000);
*(.text.Perl_ck_anoncode)
. = ALIGN(0x1000);
*(.text.Perl_ck_backtick)
. = ALIGN(0x1000);
*(.text.Perl_ck_bitop)
. = ALIGN(0x1000);
*(.text.Perl_ck_cmp)
. = ALIGN(0x1000);
*(.text.Perl_ck_concat)
. = ALIGN(0x1000);
*(.text.Perl_ck_spair)
. = ALIGN(0x1000);
*(.text.Perl_ck_delete)
. = ALIGN(0x1000);
*(.text.Perl_ck_eof)
. = ALIGN(0x1000);
*(.text.Perl_ck_eval)
. = ALIGN(0x1000);
*(.text.Perl_ck_exec)
. = ALIGN(0x1000);
*(.text.Perl_ck_exists)
. = ALIGN(0x1000);
*(.text.Perl_ck_rvconst)
. = ALIGN(0x1000);
*(.text.Perl_ck_glob)
. = ALIGN(0x1000);
*(.text.Perl_ck_grep)
. = ALIGN(0x1000);
*(.text.Perl_ck_index)
. = ALIGN(0x1000);
*(.text.Perl_ck_lfun)
. = ALIGN(0x1000);
*(.text.Perl_ck_defined)
. = ALIGN(0x1000);
*(.text.Perl_ck_rfun)
. = ALIGN(0x1000);
*(.text.Perl_ck_readline)
. = ALIGN(0x1000);
*(.text.Perl_ck_listiob)
. = ALIGN(0x1000);
*(.text.Perl_ck_smartmatch)
. = ALIGN(0x1000);
*(.text.Perl_ck_sassign)
. = ALIGN(0x1000);
*(.text.Perl_ck_match)
. = ALIGN(0x1000);
*(.text.Perl_ck_method)
. = ALIGN(0x1000);
*(.text.Perl_ck_null)
. = ALIGN(0x1000);
*(.text.Perl_ck_open)
. = ALIGN(0x1000);
*(.text.Perl_ck_prototype)
. = ALIGN(0x1000);
*(.text.Perl_ck_refassign)
. = ALIGN(0x1000);
*(.text.Perl_ck_repeat)
. = ALIGN(0x1000);
*(.text.Perl_ck_require)
. = ALIGN(0x1000);
*(.text.Perl_ck_return)
. = ALIGN(0x1000);
*(.text.Perl_ck_select)
. = ALIGN(0x1000);
*(.text.Perl_ck_shift)
. = ALIGN(0x1000);
*(.text.Perl_ck_sort)
. = ALIGN(0x1000);
*(.text.Perl_ck_split)
. = ALIGN(0x1000);
*(.text.Perl_ck_stringify)
. = ALIGN(0x1000);
*(.text.Perl_ck_join)
. = ALIGN(0x1000);
*(.text.Perl_ck_entersub_args_proto_or_list)
. = ALIGN(0x1000);
*(.text.Perl_ck_entersub_args_core)
. = ALIGN(0x1000);
*(.text.Perl_ck_subr)
. = ALIGN(0x1000);
*(.text.Perl_ck_svconst)
. = ALIGN(0x1000);
*(.text.Perl_ck_trunc)
. = ALIGN(0x1000);
*(.text.Perl_ck_substr)
. = ALIGN(0x1000);
*(.text.Perl_ck_tell)
. = ALIGN(0x1000);
*(.text.Perl_ck_each)
. = ALIGN(0x1000);
*(.text.Perl_ck_length)
. = ALIGN(0x1000);
*(.text.Perl_ck_fun .text.Perl_pad_alloc)
. = ALIGN(0x1000);
*(.text.Perl_newUNOP_AUX .text.S_maybe_multideref .text.Perl_rpeep .text.S_aassign_common_vars .text.S_aassign_common_vars_aliases_only)
. = ALIGN(0x1000);
*(.text.Perl_peep)
. = ALIGN(0x1000);
*(.text.Perl_pp_tie)
. = ALIGN(0x1000);
*(.text.Perl_pp_untie)
. = ALIGN(0x1000);
*(.text.Perl_pp_tied)
. = ALIGN(0x1000);
*(.text.Perl_defelem_target)
. = ALIGN(0x1000);
*(.text.Perl_pp_dbmopen)
. = ALIGN(0x1000);
*(.text.Perl_pp_sselect)
. = ALIGN(0x1000);
*(.text.Perl_pp_select)
. = ALIGN(0x1000);
*(.text.Perl_pp_getc)
. = ALIGN(0x1000);
*(.text.Perl_pp_enterwrite)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavewrite)
. = ALIGN(0x1000);
*(.text.S_doform)
. = ALIGN(0x1000);
*(.text.Perl_pp_prtf)
. = ALIGN(0x1000);
*(.text.Perl_pp_sysopen)
. = ALIGN(0x1000);
*(.text.Perl_pp_sysread)
. = ALIGN(0x1000);
*(.text.Perl_pp_syswrite)
. = ALIGN(0x1000);
*(.text.Perl_pp_eof)
. = ALIGN(0x1000);
*(.text.Perl_do_eof)
. = ALIGN(0x1000);
*(.text.Perl_pp_tell)
. = ALIGN(0x1000);
*(.text.Perl_pp_sysseek)
. = ALIGN(0x1000);
*(.text.Perl_pp_truncate)
. = ALIGN(0x1000);
*(.text.Perl_pp_ioctl)
. = ALIGN(0x1000);
*(.text.Perl_pp_flock)
. = ALIGN(0x1000);
*(.text.Perl_pp_sockpair)
. = ALIGN(0x1000);
*(.text.Perl_pp_stat)
. = ALIGN(0x1000);
*(.text.Perl_cando .text.Perl_pp_ftrread)
. = ALIGN(0x1000);
*(.text.Perl_pp_ftis)
. = ALIGN(0x1000);
*(.text.Perl_pp_ftrowned)
. = ALIGN(0x1000);
*(.text.Perl_my_stat_flags)
. = ALIGN(0x1000);
*(.text.Perl_pp_ftlink)
. = ALIGN(0x1000);
*(.text.Perl_my_lstat_flags)
. = ALIGN(0x1000);
*(.text.Perl_pp_fttty)
. = ALIGN(0x1000);
*(.text.Perl_pp_fttext)
. = ALIGN(0x1000);
*(.text.S_try_amagic_ftest)
. = ALIGN(0x1000);
*(.text.Perl_nothreadhook)
. = ALIGN(0x1000);
*(.text.S_Internals_V)
. = ALIGN(0x1000);
*(.text.read_e_script)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_popped)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_open)
. = ALIGN(0x1000);
*(.text.PerlIOBase_binmode)
. = ALIGN(0x1000);
*(.text.PerlIOBase_fileno)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_dup)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_read)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_seek)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_tell)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_close)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_fill)
. = ALIGN(0x1000);
*(.text.PerlIOBase_eof)
. = ALIGN(0x1000);
*(.text.PerlIOBase_error)
. = ALIGN(0x1000);
*(.text.PerlIOBase_clearerr)
. = ALIGN(0x1000);
*(.text.PerlIOBase_setlinebuf)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_get_base)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_bufsiz)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_get_ptr)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_get_cnt)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_set_ptrcnt)
. = ALIGN(0x1000);
*(.text.PerlIOPending_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOPending_read)
. = ALIGN(0x1000);
*(.text.PerlIOPending_seek)
. = ALIGN(0x1000);
*(.text.PerlIOPending_close)
. = ALIGN(0x1000);
*(.text.PerlIOPending_flush)
. = ALIGN(0x1000);
*(.text.PerlIOPending_fill)
. = ALIGN(0x1000);
*(.text.PerlIOPending_set_ptrcnt)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOBase_popped)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_open)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_fileno)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_dup)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_read)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_unread)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_write)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_seek)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_tell)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_close)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_flush)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_fill)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_eof)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_error)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_clearerr)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_setlinebuf)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_get_base)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_get_bufsiz)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_get_ptr)
. = ALIGN(0x1000);
*(.text.PerlIOStdio_get_cnt)
. = ALIGN(0x1000);
*(.text.S_lockcnt_dec)
. = ALIGN(0x1000);
*(.text.PerlIOUtf8_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOBase_open)
. = ALIGN(0x1000);
*(.text.PerlIOPop_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_binmode)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_unread)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_write)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_write)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_flush)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_flush)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_get_cnt)
. = ALIGN(0x1000);
*(.text.PerlIOCrlf_set_ptrcnt)
. = ALIGN(0x1000);
*(.text.PerlIORaw_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_open)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_fileno)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_dup)
. = ALIGN(0x1000);
*(.text.Perl_croak_no_mem)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_read)
. = ALIGN(0x1000);
*(.text.PerlIOBase_unread)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_write)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_seek)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_tell)
. = ALIGN(0x1000);
*(.text.PerlIOUnix_close)
. = ALIGN(0x1000);
*(.text.PerlIOBase_noop_ok)
. = ALIGN(0x1000);
*(.text.PerlIOBase_noop_fail)
. = ALIGN(0x1000);
*(.text.XS_PerlIO__Layer__NoWarnings)
. = ALIGN(0x1000);
*(.text.XS_PerlIO__Layer__find)
. = ALIGN(0x1000);
*(.text.Perl_foldEQ)
. = ALIGN(0x1000);
*(.text.Perl_foldEQ_latin1)
. = ALIGN(0x1000);
*(.text.Perl_foldEQ_locale)
. = ALIGN(0x1000);
*(.text.sig_trap)
. = ALIGN(0x1000);
*(.text.Perl_pp_av2arylen)
. = ALIGN(0x1000);
*(.text.Perl_pp_pos)
. = ALIGN(0x1000);
*(.text.Perl_pp_rv2cv)
. = ALIGN(0x1000);
*(.text.Perl_pp_prototype)
. = ALIGN(0x1000);
*(.text.Perl_pp_anoncode)
. = ALIGN(0x1000);
*(.text.Perl_pp_srefgen)
. = ALIGN(0x1000);
*(.text.Perl_pp_refgen)
. = ALIGN(0x1000);
*(.text.Perl_pp_ref)
. = ALIGN(0x1000);
*(.text.Perl_sv_nosharing)
. = ALIGN(0x1000);
*(.text.Perl_sv_destroyable)
. = ALIGN(0x1000);
*(.text.Perl_newHVhv .text.S_mro_get_linear_isa_dfs)
. = ALIGN(0x1000);
*(.text.XS_mro_method_changed_in)
. = ALIGN(0x1000);
*(.text.Perl_sv_nounlocking)
. = ALIGN(0x1000);
*(.text.Perl_pp_srand)
. = ALIGN(0x1000);
*(.text.Perl_pp_int)
. = ALIGN(0x1000);
*(.text.Perl_pp_abs)
. = ALIGN(0x1000);
*(.text.Perl_try_amagic_un)
. = ALIGN(0x1000);
*(.text.Perl_pp_oct)
. = ALIGN(0x1000);
*(.text.Perl_pp_length)
. = ALIGN(0x1000);
*(.text.Perl_pp_substr)
. = ALIGN(0x1000);
*(.text.Perl_pp_vec)
. = ALIGN(0x1000);
*(.text.Perl_do_vecget)
. = ALIGN(0x1000);
*(.text.Perl_pp_index)
. = ALIGN(0x1000);
*(.text.Perl_pp_sprintf)
. = ALIGN(0x1000);
*(.text.Perl_do_sprintf)
. = ALIGN(0x1000);
*(.text.Perl_pp_ord)
. = ALIGN(0x1000);
*(.text.Perl_pp_chr)
. = ALIGN(0x1000);
*(.text.Perl_pp_crypt)
. = ALIGN(0x1000);
*(.text.Perl_pp_ucfirst)
. = ALIGN(0x1000);
*(.text.Perl__to_utf8_title_flags)
. = ALIGN(0x1000);
*(.text.Perl_pp_uc)
. = ALIGN(0x1000);
*(.text.Perl__to_utf8_upper_flags)
. = ALIGN(0x1000);
*(.text.Perl_pp_lc)
. = ALIGN(0x1000);
*(.text.Perl_pp_quotemeta)
. = ALIGN(0x1000);
*(.text.Perl_pp_fc)
. = ALIGN(0x1000);
*(.text.Perl_pp_aslice)
. = ALIGN(0x1000);
*(.text.Perl_pp_kvaslice)
. = ALIGN(0x1000);
*(.text.Perl_pp_rkeys)
. = ALIGN(0x1000);
*(.text.Perl_pp_akeys)
. = ALIGN(0x1000);
*(.text.Perl_pp_each)
. = ALIGN(0x1000);
*(.text.Perl_pp_aeach)
. = ALIGN(0x1000);
*(.text.Perl_pp_delete)
. = ALIGN(0x1000);
*(.text.Perl_pp_exists)
. = ALIGN(0x1000);
*(.text.Perl_pp_hslice)
. = ALIGN(0x1000);
*(.text.Perl_pp_kvhslice)
. = ALIGN(0x1000);
*(.text.Perl_pp_list)
. = ALIGN(0x1000);
*(.text.Perl_pp_lslice)
. = ALIGN(0x1000);
*(.text.Perl_pp_anonhash)
. = ALIGN(0x1000);
*(.text.Perl_pp_splice)
. = ALIGN(0x1000);
*(.text.Perl_pp_push)
. = ALIGN(0x1000);
*(.text.Perl_pp_shift)
. = ALIGN(0x1000);
*(.text.Perl_pp_unshift)
. = ALIGN(0x1000);
*(.text.Perl_find_rundefsv .text.Perl_pp_reverse)
. = ALIGN(0x1000);
*(.text.Perl_pp_split)
. = ALIGN(0x1000);
*(.text.Perl_pp_once)
. = ALIGN(0x1000);
*(.text.Perl_pp_lock)
. = ALIGN(0x1000);
*(.text.S_refto)
. = ALIGN(0x1000);
*(.text.Perl_unimplemented_op)
. = ALIGN(0x1000);
*(.text.Perl_find_rundefsv2 .text.Perl_pp_coreargs)
. = ALIGN(0x1000);
*(.text.Perl_pp_runcv)
. = ALIGN(0x1000);
*(.text.Perl_pp_refassign)
. = ALIGN(0x1000);
*(.text.Perl_pp_lvref)
. = ALIGN(0x1000);
*(.text.Perl_pp_lvrefslice)
. = ALIGN(0x1000);
*(.text.S_localise_aelem_lval .text.S_localise_helem_lval)
. = ALIGN(0x1000);
*(.text.Perl_pp_lvavref)
. = ALIGN(0x1000);
*(.text.Perl_pp_padav)
. = ALIGN(0x1000);
*(.text.Perl_pp_anonconst)
. = ALIGN(0x1000);
*(.text.Perl_pp_wantarray)
. = ALIGN(0x1000);
*(.text.Perl_pp_regcreset)
. = ALIGN(0x1000);
*(.text.Perl_pp_regcomp)
. = ALIGN(0x1000);
*(.text.Perl_pp_substcont)
. = ALIGN(0x1000);
*(.text.Perl_pp_formline)
. = ALIGN(0x1000);
*(.text.Perl_pp_grepstart)
. = ALIGN(0x1000);
*(.text.Perl_pp_mapwhile)
. = ALIGN(0x1000);
*(.text.Perl_pp_range)
. = ALIGN(0x1000);
*(.text.Perl_pp_flip)
. = ALIGN(0x1000);
*(.text.Perl_pp_flop)
. = ALIGN(0x1000);
*(.text.Perl_pp_xor)
. = ALIGN(0x1000);
*(.text.Perl_pp_caller)
. = ALIGN(0x1000);
*(.text.Perl_caller_cx)
. = ALIGN(0x1000);
*(.text.Perl_pp_reset)
. = ALIGN(0x1000);
*(.text.Perl_sv_resetpvn)
. = ALIGN(0x1000);
*(.text.Perl_pp_dbstate)
. = ALIGN(0x1000);
*(.text.Perl_pp_enter)
. = ALIGN(0x1000);
*(.text.Perl_pp_leave)
. = ALIGN(0x1000);
*(.text.Perl_pp_enteriter)
. = ALIGN(0x1000);
*(.text.Perl_pp_enterloop)
. = ALIGN(0x1000);
*(.text.Perl_pp_leaveloop)
. = ALIGN(0x1000);
*(.text.Perl_pp_return)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavesublv)
. = ALIGN(0x1000);
*(.text.S_return_lvalues)
. = ALIGN(0x1000);
*(.text.Perl_pp_last)
. = ALIGN(0x1000);
*(.text.Perl_pp_next)
. = ALIGN(0x1000);
*(.text.Perl_pp_redo)
. = ALIGN(0x1000);
*(.text.S_unwind_loop)
. = ALIGN(0x1000);
*(.text.Perl_pp_goto .text.S_dofindlabel)
. = ALIGN(0x1000);
*(.text.Perl_pp_exit)
. = ALIGN(0x1000);
*(.text.Perl_pp_require .text.S_doopen_pm .text.S_check_type_and_open)
. = ALIGN(0x1000);
*(.text.PerlIO_open)
. = ALIGN(0x1000);
*(.text.S_run_user_filter)
. = ALIGN(0x1000);
*(.text.Perl_pp_hintseval)
. = ALIGN(0x1000);
*(.text.Perl_pp_entereval)
. = ALIGN(0x1000);
*(.text.Perl_filter_read)
. = ALIGN(0x1000);
*(.text.Perl_filter_add)
. = ALIGN(0x1000);
*(.text.Perl_populate_isa)
. = ALIGN(0x1000);
*(.text.PerlIO_puts .text.S_usage)
. = ALIGN(0x1000);
*(.text.Perl_PerlIO_stdout)
. = ALIGN(0x1000);
*(.text.Perl_newSVpvn .text.S_minus_v .text.S_SvREFCNT_dec_NN)
. = ALIGN(0x1000);
*(.text.Perl_moreswitches .text.S_incpush .text.Perl_parse_unicode_opts)
. = ALIGN(0x1000);
*(.text.S_newGIVWHENOP)
. = ALIGN(0x1000);
*(.text.S_looks_like_bool)
. = ALIGN(0x1000);
*(.text.Perl_lex_peek_unichar)
. = ALIGN(0x1000);
*(.text.Perl_lex_next_chunk .text.S_update_debugger_info)
. = ALIGN(0x1000);
*(.text.S_parse_ident)
. = ALIGN(0x1000);
*(.text.Perl_lex_read_space .text.S_incline)
. = ALIGN(0x1000);
*(.text.Perl_lex_grow_linestr)
. = ALIGN(0x1000);
*(.text.Perl_sv_cat_decode .text.Perl_yylex .text.S_sublex_done .text.S_force_ident .text.S_intuit_more .text.S_tokeq .text.S_new_constant .text.S_force_word .text.S_check_uni .text.S_scan_ident .text.S_scan_str .text.S_sublex_start .text.S_no_op .text.S_scan_pat .text.Perl_scan_num .text.S_intuit_method .text.S_lop .text.S_tokenize_use .text.S_checkcomma .text.S_force_version .text.S_pmflag .text.Perl_allocmy)
. = ALIGN(0x1000);
*(.text.S_parse_recdescent_for_op .text.Perl_parse_subsignature .text.S_parse_opt_lexvar .text.Perl_op_prepend_elem .text.Perl_my_attrs .text.S_my_kid .text.Perl_op_append_list .text.Perl_bind_match .text.Perl_newMETHOP .text.Perl_package .text.Perl_dofile .text.Perl_newASSIGNOP .text.S_assignment_type .text.Perl_newRANGE .text.Perl_newLOOPOP .text.Perl_newWHILEOP .text.Perl_newFOROP .text.Perl_newLOOPEX .text.Perl_newMYSUB .text.Perl_newFORM .text.Perl_yyparse .text.Perl_op_scope .text.Perl_block_start .text.Perl_block_end .text.Perl_newPROG .text.Perl_localize .text.Perl_jmaybe .text.Perl_pad_block_start .text.Perl_pad_leavemy .text.Perl_savesharedpv)
. = ALIGN(0x1000);
*(.text.Perl_init_argv_symbols)
. = ALIGN(0x1000);
*(.text.Perl_my_setenv)
. = ALIGN(0x1000);
*(.text.Perl_init_debugger)
. = ALIGN(0x1000);
*(.text.S_ref_array_or_hash)
. = ALIGN(0x1000);
*(.text.Perl_pad_add_name_pvn)
. = ALIGN(0x1000);
*(.text.Perl_gv_override)
. = ALIGN(0x1000);
*(.text.S_set_haseval)
. = ALIGN(0x1000);
*(.text.Perl_pad_add_anon)
. = ALIGN(0x1000);
*(.text.Perl_pmruntime)
. = ALIGN(0x1000);
*(.text.Perl_newPVOP)
. = ALIGN(0x1000);
*(.text.Perl_rv2cv_op_cv)
. = ALIGN(0x1000);
*(.text.Perl_current_re_engine)
. = ALIGN(0x1000);
*(.text.Perl_init_dbargs)
. = ALIGN(0x1000);
*(.text.S_doeval .text.S_try_yyparse)
. = ALIGN(0x1000);
*(.text.Perl_refcounted_he_chain_2hv)
. = ALIGN(0x1000);
*(.text.Perl_pp_leaveeval)
. = ALIGN(0x1000);
*(.text.Perl_pp_entertry)
. = ALIGN(0x1000);
*(.text.S_docatch)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavetry)
. = ALIGN(0x1000);
*(.text.Perl_pp_entergiven)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavegiven)
. = ALIGN(0x1000);
*(.text.Perl_pp_smartmatch .text.S_do_smartmatch .text.S_matcher_matches_sv)
. = ALIGN(0x1000);
*(.text.Perl_newPMOP)
. = ALIGN(0x1000);
*(.text.Perl_pp_enterwhen)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavewhen)
. = ALIGN(0x1000);
*(.text.S_leave_common)
. = ALIGN(0x1000);
*(.text.Perl_pp_continue)
. = ALIGN(0x1000);
*(.text.Perl_pp_break)
. = ALIGN(0x1000);
*(.text.Perl_pp_const)
. = ALIGN(0x1000);
*(.text.Perl_pp_nextstate)
. = ALIGN(0x1000);
*(.text.Perl_pp_gvsv)
. = ALIGN(0x1000);
*(.text.Perl_pp_null)
. = ALIGN(0x1000);
*(.text.Perl_pp_pushmark)
. = ALIGN(0x1000);
*(.text.Perl_pp_stringify)
. = ALIGN(0x1000);
*(.text.Perl_pp_gv)
. = ALIGN(0x1000);
*(.text.Perl_pp_and)
. = ALIGN(0x1000);
*(.text.Perl_pp_sassign)
. = ALIGN(0x1000);
*(.text.Perl_pp_cond_expr)
. = ALIGN(0x1000);
*(.text.Perl_pp_unstack)
. = ALIGN(0x1000);
*(.text.Perl_pp_concat)
. = ALIGN(0x1000);
*(.text.Perl_pp_padrange)
. = ALIGN(0x1000);
*(.text.Perl_pp_padsv)
. = ALIGN(0x1000);
*(.text.Perl_pp_readline)
. = ALIGN(0x1000);
*(.text.S_rv2gv)
. = ALIGN(0x1000);
*(.text.Perl_pp_eq)
. = ALIGN(0x1000);
*(.text.Perl_do_ncmp)
. = ALIGN(0x1000);
*(.text.Perl_pp_preinc)
. = ALIGN(0x1000);
*(.text.Perl_pp_or)
. = ALIGN(0x1000);
*(.text.Perl_pp_defined)
. = ALIGN(0x1000);
*(.text.Perl_pp_add)
. = ALIGN(0x1000);
*(.text.Perl_try_amagic_bin)
. = ALIGN(0x1000);
*(.text.Perl_pp_aelemfast)
. = ALIGN(0x1000);
*(.text.Perl_pp_join)
. = ALIGN(0x1000);
*(.text.Perl_pp_pushre)
. = ALIGN(0x1000);
*(.text.Perl_pp_print)
. = ALIGN(0x1000);
*(.text.S_pushav)
. = ALIGN(0x1000);
*(.text.Perl_hv_scalar .text.Perl_magic_scalarpack)
. = ALIGN(0x1000);
*(.text.Perl_softref2xv)
. = ALIGN(0x1000);
*(.text.Perl_do_kv)
. = ALIGN(0x1000);
*(.text.Perl_save_ary)
. = ALIGN(0x1000);
*(.text.Perl_pp_rv2av)
. = ALIGN(0x1000);
*(.text.Perl_pp_aassign)
. = ALIGN(0x1000);
*(.text.Perl_pp_qr)
. = ALIGN(0x1000);
*(.text.S_cv_clone)
. = ALIGN(0x1000);
*(.text.Perl_pp_match)
. = ALIGN(0x1000);
*(.text.Perl_pp_helem)
. = ALIGN(0x1000);
*(.text.S_softref2xv_lite .text.Perl_pp_multideref)
. = ALIGN(0x1000);
*(.text.Perl_save_hdelete .text.Perl_save_helem_flags)
. = ALIGN(0x1000);
*(.text.Perl_pp_iter)
. = ALIGN(0x1000);
*(.text.Perl_sv_inc_nomg)
. = ALIGN(0x1000);
*(.text.Perl_pp_subst)
. = ALIGN(0x1000);
*(.text.Perl_rxres_save)
. = ALIGN(0x1000);
*(.text.Perl_pp_grepwhile)
. = ALIGN(0x1000);
*(.text.Perl_pp_leavesub)
. = ALIGN(0x1000);
*(.text.Perl_pp_entersub)
. = ALIGN(0x1000);
*(.text.Perl_get_db_sub)
. = ALIGN(0x1000);
*(.text.Perl_pp_aelem)
. = ALIGN(0x1000);
*(.text.Perl_newSVavdefelem)
. = ALIGN(0x1000);
*(.text.Perl_save_aelem_flags)
. = ALIGN(0x1000);
*(.text.Perl_av_reify)
. = ALIGN(0x1000);
*(.text.Perl_vivify_ref)
. = ALIGN(0x1000);
*(.text.Perl_pp_method)
. = ALIGN(0x1000);
*(.text.Perl_pp_method_named)
. = ALIGN(0x1000);
*(.text.Perl_pp_method_super)
. = ALIGN(0x1000);
*(.text.Perl_pp_method_redir)
. = ALIGN(0x1000);
*(.text.Perl_pp_method_redir_super)
. = ALIGN(0x1000);
*(.text.S_opmethod_stash)
. = ALIGN(0x1000);
*(.text.Perl_pp_unpack)
. = ALIGN(0x1000);
*(.text.Perl_unpackstring .text.S_unpack_rec)
. = ALIGN(0x1000);
*(.text.Perl_pp_pack)
. = ALIGN(0x1000);
*(.text.S_next_symbol .text.S_utf8_to_bytes .text.S_group_end .text.S_measure_struct)
. = ALIGN(0x1000);
*(.text.S_pack_rec .text.marked_upgrade .text.S_sv_check_infnan)
. = ALIGN(0x1000);
*(.text.cmpindir)
. = ALIGN(0x1000);
*(.text.cmpindir_desc)
. = ALIGN(0x1000);
*(.text.cmp_desc)
. = ALIGN(0x1000);
*(.text.Perl_pp_sort)
. = ALIGN(0x1000);
*(.text.S_sortcv_stacked)
. = ALIGN(0x1000);
*(.text.S_sortcv)
. = ALIGN(0x1000);
*(.text.S_sortcv_xsub)
. = ALIGN(0x1000);
*(.text.S_sv_i_ncmp)
. = ALIGN(0x1000);
*(.text.S_amagic_i_ncmp)
. = ALIGN(0x1000);
*(.text.S_sv_ncmp)
. = ALIGN(0x1000);
*(.text.S_amagic_ncmp)
. = ALIGN(0x1000);
*(.text.S_amagic_cmp)
. = ALIGN(0x1000);
*(.text.Perl_pp_backtick)
. = ALIGN(0x1000);
*(.text.Perl_pp_glob)
. = ALIGN(0x1000);
*(.text.Perl_pp_rcatline)
. = ALIGN(0x1000);
*(.text.Perl_start_glob .text.Perl_do_readline)
. = ALIGN(0x1000);
*(.text.Perl_nextargv)
. = ALIGN(0x1000);
*(.text.Perl_do_open_raw)
. = ALIGN(0x1000);
*(.text.Perl_sv_gets)
. = ALIGN(0x1000);
*(.text.Perl_sv_2pvutf8)
. = ALIGN(0x1000);
*(.text.Perl_pp_warn)
. = ALIGN(0x1000);
*(.text.Perl_pp_die)
. = ALIGN(0x1000);
*(.text.Perl_die_sv)
. = ALIGN(0x1000);
*(.text.Perl_pp_open)
. = ALIGN(0x1000);
*(.text.Perl_pp_close)
. = ALIGN(0x1000);
*(.text.Perl_pp_pipe_op)
. = ALIGN(0x1000);
*(.text.Perl_pp_fileno)
. = ALIGN(0x1000);
*(.text.Perl_pp_umask)
. = ALIGN(0x1000);
*(.text.Perl_pp_binmode)
. = ALIGN(0x1000);
*(.text.Perl_tied_method)
. = ALIGN(0x1000);
*(.text.Perl_report_evil_fh)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_strict_comment)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_boolean_attribute_value)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_ignore_tags)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_handler)
. = ALIGN(0x1000);
*(.text.XS_HTML__Entities_decode_entities)
. = ALIGN(0x1000);
*(.text.XS_HTML__Entities__decode_entities)
. = ALIGN(0x1000);
*(.text.XS_HTML__Entities__probably_utf8_chunk)
. = ALIGN(0x1000);
*(.text.XS_HTML__Entities_UNICODE_SUPPORT)
. = ALIGN(0x1000);
*(.text.boot_mro)
. = ALIGN(0x1000);
*(.text.XS_mro_get_linear_isa)
. = ALIGN(0x1000);
*(.text.Perl_mro_set_mro .text.XS_mro_set_mro)
. = ALIGN(0x1000);
*(.text.XS_mro_get_mro)
. = ALIGN(0x1000);
*(.text.XS_mro_get_isarev)
. = ALIGN(0x1000);
*(.text.XS_mro_is_universal)
. = ALIGN(0x1000);
*(.text.XS_mro_invalidate_all_method_caches)
. = ALIGN(0x1000);
*(.text.XS_mro_get_pkg_gen)
. = ALIGN(0x1000);
*(.text.XS_mro__nextcan)
. = ALIGN(0x1000);
*(.text.Perl_sv_dec_nomg)
. = ALIGN(0x1000);
*(.text.Perl_mro_set_private_data)
. = ALIGN(0x1000);
*(.text.S_mro_get_linear_isa_c3)
. = ALIGN(0x1000);
*(.text.boot_re)
. = ALIGN(0x1000);
*(.text.XS_re_install)
. = ALIGN(0x1000);
*(.text.XS_re_regmust)
. = ALIGN(0x1000);
*(.text.my_re_compile)
. = ALIGN(0x1000);
*(.text.Perl__new_invlist .text.my_re_op_compile .text.S_concat_pat.5788 .text.S_pat_upgrade_to_utf8 .text.S_reg.5816 .text.my_regprop .text.S_ssc_anything .text.S_study_chunk.5873 .text.S_scan_commit.5876 .text.S_is_ssc_worth_it.5877 .text.S_ssc_finalize .text.my_regdump .text.S_dumpuntil .text.S_invlist_clone .text.S_populate_ANYOF_from_invlist.5928 .text.S_set_ANYOF_arg.5929 .text.S_invlist_array .text.S_invlist_set_len .text.S_ssc_or.5975 .text.S_ssc_and.5976 .text.S_make_trie.5985 .text.S_add_above_Latin1_folds.5996 .text.S_get_ANYOF_cp_list_for_ssc.6078 .text.S_ssc_is_cp_posixl_init .text.S_put_charclass_bitmap_innards .text.S_put_range .text.S_put_code_point .text.S_re_croak2.6189 .text.S_regnode_guts .text.S_nextchar.6195 .text.S_reg_scan_name.6197 .text.S_regtail .text.S_regbranch.6222 .text.S_handle_regex_sets.6228 .text.S_parse_lparen_question_flags.6230 .text.S_reginsert .text.S_regtail_study .text.S_regpatws .text.S_could_it_be_a_POSIX_class .text.S_regclass.6270 .text.S_grok_bslash_N.6312 .text.S_add_multi_match .text.S_grok_bslash_o .text.S_grok_bslash_x.6330 .text.S_alloc_maybe_populate_EXACT.6359 .text.S_regatom.6392)
. = ALIGN(0x1000);
*(.text.S_unwind_scan_frames.5991)
. = ALIGN(0x1000);
*(.text.Perl_pp_chdir)
. = ALIGN(0x1000);
*(.text.Perl_apply .text.Perl_pp_chown)
. = ALIGN(0x1000);
*(.text.Perl_pp_chroot)
. = ALIGN(0x1000);
*(.text.Perl_same_dirent .text.Perl_pp_rename)
. = ALIGN(0x1000);
*(.text.Perl_pp_link)
. = ALIGN(0x1000);
*(.text.Perl_pp_readlink)
. = ALIGN(0x1000);
*(.text.Perl_pp_mkdir)
. = ALIGN(0x1000);
*(.text.Perl_pp_rmdir)
. = ALIGN(0x1000);
*(.text.Perl_pp_open_dir)
. = ALIGN(0x1000);
*(.text.Perl_pp_readdir)
. = ALIGN(0x1000);
*(.text.Perl_pp_telldir)
. = ALIGN(0x1000);
*(.text.Perl_pp_seekdir)
. = ALIGN(0x1000);
*(.text.Perl_pp_rewinddir)
. = ALIGN(0x1000);
*(.text.Perl_pp_closedir)
. = ALIGN(0x1000);
*(.text.Perl_pp_fork)
. = ALIGN(0x1000);
*(.text.Perl_pp_wait)
. = ALIGN(0x1000);
*(.text.Perl_pp_waitpid)
. = ALIGN(0x1000);
*(.text.Perl_pp_system)
. = ALIGN(0x1000);
*(.text.Perl_pp_exec)
. = ALIGN(0x1000);
*(.text.Perl_pp_getppid)
. = ALIGN(0x1000);
*(.text.Perl_pp_getpgrp)
. = ALIGN(0x1000);
*(.text.Perl_pp_setpgrp)
. = ALIGN(0x1000);
*(.text.Perl_pp_getpriority)
. = ALIGN(0x1000);
*(.text.Perl_pp_setpriority)
. = ALIGN(0x1000);
*(.text.Perl_pp_time)
. = ALIGN(0x1000);
*(.text.Perl_pp_tms)
. = ALIGN(0x1000);
*(.text.Perl_sv_setpvf_mg .text.Perl_pp_gmtime .text.S_gmtime64_r)
. = ALIGN(0x1000);
*(.text.Perl_pp_alarm)
. = ALIGN(0x1000);
*(.text.Perl_pp_sleep)
. = ALIGN(0x1000);
*(.text.Perl_pp_shmwrite)
. = ALIGN(0x1000);
*(.text.Perl_pp_semget)
. = ALIGN(0x1000);
*(.text.Perl_pp_semctl)
. = ALIGN(0x1000);
*(.text.Perl_pp_ghostent)
. = ALIGN(0x1000);
*(.text.Perl_pp_gnetent)
. = ALIGN(0x1000);
*(.text.Perl_pp_gprotoent)
. = ALIGN(0x1000);
*(.text.Perl_pp_gservent)
. = ALIGN(0x1000);
*(.text.Perl_pp_shostent)
. = ALIGN(0x1000);
*(.text.Perl_pp_ehostent)
. = ALIGN(0x1000);
*(.text.Perl_pp_gpwent)
. = ALIGN(0x1000);
*(.text.Perl_pp_ggrent)
. = ALIGN(0x1000);
*(.text.Perl_pp_getlogin)
. = ALIGN(0x1000);
*(.text.Perl_pp_syscall)
. = ALIGN(0x1000);
*(.text.Perl_re_compile)
. = ALIGN(0x1000);
*(.text.Perl_re_intuit_string)
. = ALIGN(0x1000);
*(.text.Perl_regfree_internal)
. = ALIGN(0x1000);
*(.text.Perl_reg_numbered_buff_fetch)
. = ALIGN(0x1000);
*(.text.Perl_reg_numbered_buff_store)
. = ALIGN(0x1000);
*(.text.Perl_reg_numbered_buff_length)
. = ALIGN(0x1000);
*(.text.Perl_reg_named_buff_fetch .text.Perl_reg_named_buff_all .text.Perl_reg_named_buff_scalar .text.Perl_reg_named_buff)
. = ALIGN(0x1000);
*(.text.Perl_reg_named_buff_nextkey .text.Perl_reg_named_buff_iter)
. = ALIGN(0x1000);
*(.text.Perl_reg_qr_package)
. = ALIGN(0x1000);
*(.text.S_study_chunk .text.S_scan_commit .text.S_is_ssc_worth_it .text.S_populate_ANYOF_from_invlist .text.S_set_ANYOF_arg .text.S_ssc_or .text.S_ssc_and .text.S_make_trie .text.S_add_above_Latin1_folds .text.S_get_ANYOF_cp_list_for_ssc .text.S_re_croak2 .text.S_nextchar .text.S_reg_scan_name .text.S_regbranch .text.S_handle_regex_sets .text.S_parse_lparen_question_flags .text.S_regclass .text.S_grok_bslash_N .text.S_grok_bslash_x .text.S_alloc_maybe_populate_EXACT .text.S_regatom .text.Perl_re_op_compile .text.S_concat_pat .text.S_reg)
. = ALIGN(0x1000);
*(.text.Perl_repeatcpy)
. = ALIGN(0x1000);
*(.text.Perl_grok_oct)
. = ALIGN(0x1000);
*(.text.Perl_av_exists)
. = ALIGN(0x1000);
*(.text.boot_Cwd)
. = ALIGN(0x1000);
*(.text.XS_Cwd_CLONE)
. = ALIGN(0x1000);
*(.text.XS_Cwd_getcwd)
. = ALIGN(0x1000);
*(.text.XS_Cwd_abs_path)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix_canonpath)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix__fn_canonpath)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix_catdir)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix__fn_catdir)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix_catfile)
. = ALIGN(0x1000);
*(.text.XS_File__Spec__Unix__fn_catfile)
. = ALIGN(0x1000);
*(.text.Perl_do_join)
. = ALIGN(0x1000);
*(.text.THX_unix_canonpath)
. = ALIGN(0x1000);
*(.text.boot_Data__Dumper)
. = ALIGN(0x1000);
*(.text.XS_Data__Dumper_Dumpxs .text.DD_dump .text.sv_x .text.esc_q_utf8)
. = ALIGN(0x1000);
*(.text.XS_Data__Dumper__vstring)
. = ALIGN(0x1000);
*(.text.Perl_custom_op_register .text.boot_Devel__Peek)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_mstat)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_fill_mstats)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_mstats_fillhash)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_mstats2hash)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_Dump)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_DumpArray)
. = ALIGN(0x1000);
*(.text.Perl_op_dump .text.XS_Devel__Peek_DumpProg)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_SvREFCNT)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_DeadCode)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_CvGV)
. = ALIGN(0x1000);
*(.text.XS_Devel__Peek_runops_debug)
. = ALIGN(0x1000);
*(.text.S_ck_dump)
. = ALIGN(0x1000);
*(.text.S_pad_findlex)
. = ALIGN(0x1000);
*(.text.Perl_newDEFSVOP)
. = ALIGN(0x1000);
*(.text.Perl_pad_findmy_pvn)
. = ALIGN(0x1000);
*(.text.Perl_ck_entersub_args_proto)
. = ALIGN(0x1000);
*(.text.S_pp_dump)
. = ALIGN(0x1000);
*(.text.S_do_dump)
. = ALIGN(0x1000);
*(.text.boot_Digest__MD5)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_new)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_clone)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_DESTROY)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_add)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_addfile)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_digest)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_context)
. = ALIGN(0x1000);
*(.text.XS_Digest__MD5_md5)
. = ALIGN(0x1000);
*(.text.MD5Transform)
. = ALIGN(0x1000);
*(.text.make_mortal_sv)
. = ALIGN(0x1000);
*(.text.boot_Digest__SHA)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_shainit)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_sharewind)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_shawrite)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_newSHA)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_clone)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_DESTROY)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_sha1)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_hmac_sha1)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_hashsize)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_add)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA_digest)
. = ALIGN(0x1000);
*(.text.shafinish .text.shabase64)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA__getstate)
. = ALIGN(0x1000);
*(.text.digcpy)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA__putstate)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA__addfilebin)
. = ALIGN(0x1000);
*(.text.XS_Digest__SHA__addfileuniv)
. = ALIGN(0x1000);
*(.text.shawrite)
. = ALIGN(0x1000);
*(.text.sha1)
. = ALIGN(0x1000);
*(.text.sha256)
. = ALIGN(0x1000);
*(.text.sha512)
. = ALIGN(0x1000);
*(.text.boot_DynaLoader)
. = ALIGN(0x1000);
*(.text.XS_DynaLoader_dl_error)
. = ALIGN(0x1000);
*(.text.boot_IO)
. = ALIGN(0x1000);
*(.text.XS_IO__Seekable_getpos)
. = ALIGN(0x1000);
*(.text.PerlIO_setpos .text.XS_IO__Seekable_setpos)
. = ALIGN(0x1000);
*(.text.XS_IO__File_new_tmpfile)
. = ALIGN(0x1000);
*(.text.Perl_do_aexec5)
. = ALIGN(0x1000);
*(.text.Perl_do_exec3)
. = ALIGN(0x1000);
*(.text.Perl_taint_env)
. = ALIGN(0x1000);
*(.text.Perl_do_open6 .text.Perl_my_popen_list)
. = ALIGN(0x1000);
*(.text.S_openn_setup .text.S_openn_cleanup)
. = ALIGN(0x1000);
*(.text.Perl_my_popen)
. = ALIGN(0x1000);
*(.text.XS_IO__Poll__poll .text.Perl_my_poll)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_blocking)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_ungetc)
. = ALIGN(0x1000);
*(.text.PerlIO_ungetc)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_error)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_clearerr)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_untaint)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_flush)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_setbuf)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_setvbuf)
. = ALIGN(0x1000);
*(.text.XS_IO__Handle_sync)
. = ALIGN(0x1000);
*(.text.Perl_eval_pv .text.XS_IO__Handle__create_getline_subs)
. = ALIGN(0x1000);
*(.text.XS_IO__Socket_sockatmark)
. = ALIGN(0x1000);
*(.text.io_ck_lineseq)
. = ALIGN(0x1000);
*(.text.io_pp_nextstate)
. = ALIGN(0x1000);
*(.text.boot_MIME__Base64)
. = ALIGN(0x1000);
*(.text.XS_MIME__Base64_encode_base64)
. = ALIGN(0x1000);
*(.text.XS_MIME__Base64_decode_base64)
. = ALIGN(0x1000);
*(.text.XS_MIME__Base64_encoded_base64_length)
. = ALIGN(0x1000);
*(.text.XS_MIME__Base64_decoded_base64_length)
. = ALIGN(0x1000);
*(.text.XS_MIME__QuotedPrint_encode_qp)
. = ALIGN(0x1000);
*(.text.XS_MIME__QuotedPrint_decode_qp)
. = ALIGN(0x1000);
*(.text.Perl_sv_2pvbyte)
. = ALIGN(0x1000);
*(.text.boot_Opcode)
. = ALIGN(0x1000);
*(.text.XS_Opcode__safe_pkg_prep)
. = ALIGN(0x1000);
*(.text.XS_Opcode__safe_call_sv)
. = ALIGN(0x1000);
*(.text.Perl_gv_add_by_type)
. = ALIGN(0x1000);
*(.text.Perl_save_hash)
. = ALIGN(0x1000);
*(.text.XS_Opcode_verify_opset)
. = ALIGN(0x1000);
*(.text.XS_Opcode_invert_opset)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opset_to_ops)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opset)
. = ALIGN(0x1000);
*(.text.XS_Opcode_permit_only)
. = ALIGN(0x1000);
*(.text.set_opset_bits)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opdesc)
. = ALIGN(0x1000);
*(.text.get_op_bitspec)
. = ALIGN(0x1000);
*(.text.XS_Opcode_define_optag)
. = ALIGN(0x1000);
*(.text.XS_Opcode_empty_opset)
. = ALIGN(0x1000);
*(.text.XS_Opcode_full_opset)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opmask_add)
. = ALIGN(0x1000);
*(.text.opmask_add)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opcodes)
. = ALIGN(0x1000);
*(.text.XS_Opcode_opmask)
. = ALIGN(0x1000);
*(.text.boot_Storable)
. = ALIGN(0x1000);
*(.text.XS_Storable_init_perinterp)
. = ALIGN(0x1000);
*(.text.XS_Storable_pstore)
. = ALIGN(0x1000);
*(.text.XS_Storable_mstore)
. = ALIGN(0x1000);
*(.text.XS_Storable_pretrieve)
. = ALIGN(0x1000);
*(.text.Perl_sv_2io)
. = ALIGN(0x1000);
*(.text.XS_Storable_mretrieve)
. = ALIGN(0x1000);
*(.text.XS_Storable_dclone)
. = ALIGN(0x1000);
*(.text.do_retrieve)
. = ALIGN(0x1000);
*(.text.clean_retrieve_context .text.clean_store_context)
. = ALIGN(0x1000);
*(.text.do_store)
. = ALIGN(0x1000);
*(.text.XS_Storable_last_op_in_netorder)
. = ALIGN(0x1000);
*(.text.storable_free)
. = ALIGN(0x1000);
*(.text.old_retrieve_array)
. = ALIGN(0x1000);
*(.text.old_retrieve_hash)
. = ALIGN(0x1000);
*(.text.retrieve_undef)
. = ALIGN(0x1000);
*(.text.retrieve_integer)
. = ALIGN(0x1000);
*(.text.retrieve_double)
. = ALIGN(0x1000);
*(.text.retrieve_byte)
. = ALIGN(0x1000);
*(.text.retrieve_netint)
. = ALIGN(0x1000);
*(.text.retrieve_tied_array)
. = ALIGN(0x1000);
*(.text.retrieve_tied_hash)
. = ALIGN(0x1000);
*(.text.retrieve_tied_scalar)
. = ALIGN(0x1000);
*(.text.retrieve_other)
. = ALIGN(0x1000);
*(.text.retrieve_array)
. = ALIGN(0x1000);
*(.text.retrieve_hash)
. = ALIGN(0x1000);
*(.text.retrieve_sv_undef)
. = ALIGN(0x1000);
*(.text.retrieve_sv_yes)
. = ALIGN(0x1000);
*(.text.retrieve_sv_no)
. = ALIGN(0x1000);
*(.text.retrieve_blessed)
. = ALIGN(0x1000);
*(.text.retrieve_idx_blessed)
. = ALIGN(0x1000);
*(.text.retrieve_hook .text.scalar_call)
. = ALIGN(0x1000);
*(.text.retrieve_tied_key)
. = ALIGN(0x1000);
*(.text.retrieve_tied_idx)
. = ALIGN(0x1000);
*(.text.retrieve_utf8str)
. = ALIGN(0x1000);
*(.text.retrieve_lutf8str)
. = ALIGN(0x1000);
*(.text.retrieve_flag_hash)
. = ALIGN(0x1000);
*(.text.retrieve_code)
. = ALIGN(0x1000);
*(.text.retrieve_lscalar)
. = ALIGN(0x1000);
*(.text.retrieve_scalar)
. = ALIGN(0x1000);
*(.text.retrieve_weakref)
. = ALIGN(0x1000);
*(.text.retrieve_ref)
. = ALIGN(0x1000);
*(.text.retrieve_weakoverloaded)
. = ALIGN(0x1000);
*(.text.retrieve_overloaded)
. = ALIGN(0x1000);
*(.text.retrieve_vstring)
. = ALIGN(0x1000);
*(.text.retrieve_lvstring)
. = ALIGN(0x1000);
*(.text.retrieve)
. = ALIGN(0x1000);
*(.text.retrieve_svundef_elem)
. = ALIGN(0x1000);
*(.text.store_ref)
. = ALIGN(0x1000);
*(.text.store_scalar)
. = ALIGN(0x1000);
*(.text.store_array)
. = ALIGN(0x1000);
*(.text.store_hash)
. = ALIGN(0x1000);
*(.text.Perl_sortsv_flags .text.S_qsortsvu)
. = ALIGN(0x1000);
*(.text.store_tied)
. = ALIGN(0x1000);
*(.text.store_tied_item)
. = ALIGN(0x1000);
*(.text.Perl_av_undef)
. = ALIGN(0x1000);
*(.text.pkg_can)
. = ALIGN(0x1000);
*(.text.Perl_av_fill)
. = ALIGN(0x1000);
*(.text.Perl_ptr_table_store .text.store .text.store_blessed)
. = ALIGN(0x1000);
*(.text.sv_type)
. = ALIGN(0x1000);
*(.text.store_code)
. = ALIGN(0x1000);
*(.text.store_other)
. = ALIGN(0x1000);
*(.text.boot_Sys__Hostname)
. = ALIGN(0x1000);
*(.text.XS_Sys__Hostname_ghname)
. = ALIGN(0x1000);
*(.text.boot_Time__HiRes)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_constant)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_usleep)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_nanosleep)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_sleep)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_ualarm)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_alarm)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_gettimeofday)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_time)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_clock_gettime)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_clock_getres)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_clock_nanosleep)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_clock)
. = ALIGN(0x1000);
*(.text.XS_Time__HiRes_stat)
. = ALIGN(0x1000);
*(.text.boot_attributes)
. = ALIGN(0x1000);
*(.text.XS_attributes__modify_attrs)
. = ALIGN(0x1000);
*(.text.XS_attributes__fetch_attrs)
. = ALIGN(0x1000);
*(.text.XS_attributes__guess_stash)
. = ALIGN(0x1000);
*(.text.XS_attributes_reftype)
. = ALIGN(0x1000);
*(.text.magic_free_pstate)
. = ALIGN(0x1000);
*(.text.boot_HTML__Parser)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser__alloc_pstate)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_parse)
. = ALIGN(0x1000);
*(.text.XS_HTML__Parser_eof)
. = ALIGN(0x1000);
*(.text.Perl_sv_utf8_decode)
. = ALIGN(0x1000);
*(.text.get_pstate_hv)
. = ALIGN(0x1000);
*(.text.decode_entities)
. = ALIGN(0x1000);
*(.text.Perl_av_pop)
. = ALIGN(0x1000);
*(.text.parse .text.report_event .text.parse_buf .text.marked_section_update)
. = ALIGN(0x1000);
*(.text.my_reg_named_buff .text.my_reg_named_buff_fetch .text.my_reg_named_buff_exists .text.my_reg_named_buff_all .text.my_reg_named_buff_scalar)
. = ALIGN(0x1000);
*(.text.my_reg_named_buff_iter .text.my_reg_named_buff_firstkey .text.my_reg_named_buff_nextkey)
. = ALIGN(0x1000);
*(.text.my_reg_numbered_buff_fetch)
. = ALIGN(0x1000);
*(.text.my_reg_numbered_buff_store)
. = ALIGN(0x1000);
*(.text.my_reg_numbered_buff_length)
. = ALIGN(0x1000);
*(.text.Perl_is_utf8_string_loclen)
. = ALIGN(0x1000);
*(.text.my_reg_qr_package)
. = ALIGN(0x1000);
*(.text.my_re_intuit_string)
. = ALIGN(0x1000);
*(.text.my_regfree)
. = ALIGN(0x1000);
*(.text.my_regexec .text.S_reg_set_capture_string.6524)
. = ALIGN(0x1000);
*(.text.Perl_foldEQ_utf8_flags)
. = ALIGN(0x1000);
*(.text.Perl_fbm_instr)
. = ALIGN(0x1000);
*(.text.Perl__invlist_contents .text.Perl__get_regclass_nonbitmap_data)
. = ALIGN(0x1000);
*(.text.Perl_fbm_compile)
. = ALIGN(0x1000);
*(.text.Perl_hv_iternextsv .text.Perl__swash_inversion_hash)
. = ALIGN(0x1000);
*(.text.Perl__to_uni_fold_flags)
. = ALIGN(0x1000);
*(.text.Perl_to_utf8_case)
. = ALIGN(0x1000);
*(.text.Perl__to_utf8_fold_flags)
. = ALIGN(0x1000);
*(.text.Perl_utf8_distance)
. = ALIGN(0x1000);
*(.text.my_re_intuit_start .text.S_to_utf8_substr.6479 .text.S_to_byte_substr.6480 .text.S_find_byclass.6481 .text.S_reginclass.6482 .text.S_regmatch.6483 .text.S_isGCB.6488 .text.S_isSB.6490 .text.S_isWB.6492 .text.S_isFOO_utf8_lc.6493 .text.S_isFOO_lc.6494 .text.S_backup_one_WB.6498 .text.S_backup_one_SB.6499 .text.S_regcppush.6502 .text.S_regcppop.6505 .text.S_setup_EXACTISH_ST_c1_c2.6507 .text.S_regrepeat.6508)
. = ALIGN(0x1000);
*(.text.Perl_save_gp)
. = ALIGN(0x1000);
*(.text.Perl_sv_magicext_mglob)
. = ALIGN(0x1000);
*(.text.Perl_vivify_defelem)
. = ALIGN(0x1000);
*(.text.Perl_sv_setsv_cow)
. = ALIGN(0x1000);
*(.text.S_cleanup_regmatch_info_aux.6526)
. = ALIGN(0x1000);
*(.text.boot_arybase)
. = ALIGN(0x1000);
*(.text.XS_arybase_FETCH)
. = ALIGN(0x1000);
*(.text.XS_arybase_STORE)
. = ALIGN(0x1000);
*(.text.XS_arybase__mg_FETCH)
. = ALIGN(0x1000);
*(.text.XS_arybase__mg_STORE)
. = ALIGN(0x1000);
*(.text.ab_ck_sassign)
. = ALIGN(0x1000);
*(.text.ab_ck_aassign)
. = ALIGN(0x1000);
*(.text.ab_process_assignment)
. = ALIGN(0x1000);
*(.text.ab_ck_base)
. = ALIGN(0x1000);
*(.text.ab_pp_index)
. = ALIGN(0x1000);
*(.text.ab_pp_each)
. = ALIGN(0x1000);
*(.text.ab_pp_keys)
. = ALIGN(0x1000);
*(.text.ab_pp_av2arylen)
. = ALIGN(0x1000);
*(.text.tie)
. = ALIGN(0x1000);
*(.text.ab_pp_basearg)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_popped)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_open)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_arg)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_fileno)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_dup)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_read)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_write)
. = ALIGN(0x1000);
*(.text.Perl_sv_utf8_downgrade)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_seek)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_tell)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_close)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_flush)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_fill)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_get_base)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_bufsiz)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_get_ptr)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_get_cnt)
. = ALIGN(0x1000);
*(.text.PerlIOScalar_set_ptrcnt)
. = ALIGN(0x1000);
*(.text.boot_PerlIO__scalar)
. = ALIGN(0x1000);
*(.text.PerlIOVia_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOBase_pushed)
. = ALIGN(0x1000);
*(.text.PerlIOVia_popped)
. = ALIGN(0x1000);
*(.text.PerlIOVia_open)
. = ALIGN(0x1000);
*(.text.PerlIO_allocate)
. = ALIGN(0x1000);
*(.text.PerlIOVia_binmode)
. = ALIGN(0x1000);
*(.text.PerlIOVia_getarg)
. = ALIGN(0x1000);
*(.text.PerlIOVia_fileno)
. = ALIGN(0x1000);
*(.text.PerlIOVia_dup)
. = ALIGN(0x1000);
*(.text.PerlIOBase_dup)
. = ALIGN(0x1000);
*(.text.PerlIOVia_read)
. = ALIGN(0x1000);
*(.text.PerlIOBase_read)
. = ALIGN(0x1000);
*(.text.PerlIOVia_unread)
. = ALIGN(0x1000);
*(.text.PerlIOBuf_unread)
. = ALIGN(0x1000);
*(.text.PerlIOVia_write)
. = ALIGN(0x1000);
*(.text.PerlIOVia_seek)
. = ALIGN(0x1000);
*(.text.PerlIOVia_tell)
. = ALIGN(0x1000);
*(.text.PerlIOVia_close)
. = ALIGN(0x1000);
*(.text.PerlIOVia_flush)
. = ALIGN(0x1000);
*(.text.PerlIOVia_fill)
. = ALIGN(0x1000);
*(.text.PerlIOVia_eof)
. = ALIGN(0x1000);
*(.text.PerlIOVia_error)
. = ALIGN(0x1000);
*(.text.PerlIOVia_clearerr)
. = ALIGN(0x1000);
*(.text.PerlIOVia_setlinebuf)
. = ALIGN(0x1000);
*(.text.PerlIOVia_method)
. = ALIGN(0x1000);
*(.text.PerlIOVia_get_base)
. = ALIGN(0x1000);
*(.text.PerlIOVia_bufsiz)
. = ALIGN(0x1000);
*(.text.PerlIOVia_get_ptr)
. = ALIGN(0x1000);
*(.text.PerlIOVia_get_cnt)
. = ALIGN(0x1000);
*(.text.PerlIOVia_set_ptrcnt)
. = ALIGN(0x1000);
*(.text.boot_PerlIO__via)
. = ALIGN(0x1000);
*(.text.compare)
. = ALIGN(0x1000);
*(.text.ci_compare)
. = ALIGN(0x1000);
*(.text.boot_File__Glob)
. = ALIGN(0x1000);
*(.text.XS_File__Glob_GLOB_ERROR)
. = ALIGN(0x1000);
*(.text.XS_File__Glob_bsd_glob)
. = ALIGN(0x1000);
*(.text.XS_File__Glob_csh_glob)
. = ALIGN(0x1000);
*(.text.XS_File__Glob_bsd_glob_override)
. = ALIGN(0x1000);
*(.text.XS_File__Glob_AUTOLOAD)
. = ALIGN(0x1000);
*(.text.Perl_croak_sv)
. = ALIGN(0x1000);
*(.text.csh_glob_iter)
. = ALIGN(0x1000);
*(.text.iterate)
. = ALIGN(0x1000);
*(.text.glob_ophook)
. = ALIGN(0x1000);
*(.text.csh_glob)
. = ALIGN(0x1000);
*(.text.doglob_iter_wrapper)
. = ALIGN(0x1000);
*(.text.doglob)
. = ALIGN(0x1000);
*(.text.glob0 .text.glob2 .text.globextend .text.match)
. = ALIGN(0x1000);
*(.text.globexp1)
. = ALIGN(0x1000);
*(.text.errfunc)
. = ALIGN(0x1000);
*(.text.boot_Hash__Util)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_all_keys)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_hidden_ref_keys)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_hv_store)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_hash_seed)
. = ALIGN(0x1000);
*(.text.Perl_sv_dump .text.XS_Hash__Util_hash_value)
. = ALIGN(0x1000);
*(.text.Perl_pv_pretty)
. = ALIGN(0x1000);
*(.text.Perl_sv_catpv)
. = ALIGN(0x1000);
*(.text.Perl_dump_indent)
. = ALIGN(0x1000);
*(.text.S_sequence_num .text.Perl_do_pmop_dump .text.Perl_do_op_dump)
. = ALIGN(0x1000);
*(.text.Perl_pv_display .text.Perl_sv_peek)
. = ALIGN(0x1000);
*(.text.Perl__invlist_dump .text.Perl_do_magic_dump .text.Perl_do_sv_dump .text.Perl_do_hv_dump .text.Perl_do_gvgv_dump .text.Perl_do_gv_dump .text.Perl_do_dump_pad)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_hash_traversal_mask)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_bucket_info)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util_bucket_array)
. = ALIGN(0x1000);
*(.text.HUF_destroy_obj)
. = ALIGN(0x1000);
*(.text.HUF_watch_key_safe)
. = ALIGN(0x1000);
*(.text.HUF_watch_key_id)
. = ALIGN(0x1000);
*(.text.HUF_inc_var)
. = ALIGN(0x1000);
*(.text.boot_Hash__Util__FieldHash)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash__fieldhash)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash_id)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash_id_2obj)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash_register)
. = ALIGN(0x1000);
*(.text.HUF_new_trigger)
. = ALIGN(0x1000);
*(.text.HUF_fix_trigger .text.HUF_fix_objects .text.XS_Hash__Util__FieldHash_CLONE)
. = ALIGN(0x1000);
*(.text.HUF_get_ob_reg)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash__active_fields)
. = ALIGN(0x1000);
*(.text.XS_Hash__Util__FieldHash__test_uvar_get)
. = ALIGN(0x1000);
*(.text.boot_Tie__Hash__NamedCapture .text.tie_it)
. = ALIGN(0x1000);
*(.text.XS_Tie__Hash__NamedCapture_TIEHASH)
. = ALIGN(0x1000);
*(.text.XS_Tie__Hash__NamedCapture_FETCH)
. = ALIGN(0x1000);
*(.text.XS_Tie__Hash__NamedCapture_FIRSTKEY)
. = ALIGN(0x1000);
*(.text.XS_Tie__Hash__NamedCapture_flags)
. = ALIGN(0x1000);
*(.text.boot_List__Util)
. = ALIGN(0x1000);
*(.text.Perl_vstringify)
. = ALIGN(0x1000);
*(.text.Perl_vnormal)
. = ALIGN(0x1000);
*(.text.Perl_noperl_die .text.Perl_xs_handshake)
. = ALIGN(0x1000);
*(.text.XS_List__Util_min)
. = ALIGN(0x1000);
*(.text.XS_List__Util_sum)
. = ALIGN(0x1000);
*(.text.XS_List__Util_minstr)
. = ALIGN(0x1000);
*(.text.XS_List__Util_reduce)
. = ALIGN(0x1000);
*(.text.XS_List__Util_first)
. = ALIGN(0x1000);
*(.text.XS_List__Util_any)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairfirst)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairgrep)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairmap)
. = ALIGN(0x1000);
*(.text.Perl_pad_push)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairs)
. = ALIGN(0x1000);
*(.text.Perl_get_hv)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairkeys)
. = ALIGN(0x1000);
*(.text.XS_List__Util_pairvalues)
. = ALIGN(0x1000);
*(.text.XS_List__Util_shuffle)
. = ALIGN(0x1000);
*(.text.spec_genrand_int32)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_dualvar)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_isdual)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_blessed)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_reftype)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_refaddr)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_weaken)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_unweaken)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_isweak)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_readonly)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_tainted)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_isvstring)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_looks_like_number)
. = ALIGN(0x1000);
*(.text.XS_Scalar__Util_openhandle)
. = ALIGN(0x1000);
*(.text.XS_Sub__Util_set_prototype)
. = ALIGN(0x1000);
*(.text.XS_Sub__Util_set_subname)
. = ALIGN(0x1000);
*(.text.XS_Sub__Util_subname)
. = ALIGN(0x1000);
*(.text.Perl_croak_xs_usage)
. = ALIGN(0x1000);
*(.text.Perl_PerlIO_fileno)
. = ALIGN(0x1000);
*(.text.Perl_PerlIO_close)
. = ALIGN(0x1000);
*(.text.Perl_av_extend .text.Perl_av_extend_guts .text.Perl_av_fetch .text.S_adjust_index .text.Perl_taint_proper .text.Perl_lex_start .text.Perl_parser_free .text.Perl_validate_proto .text.Perl_yyerror_pvn .text.Perl_scan_vstring .text.Perl_start_subparse .text.Perl_sv_derived_from_pvn .text.S_isa_lookup .text.Perl_uvoffuni_to_utf8_flags .text.Perl_is_utf8_string .text.Perl_utf8n_to_uvchr .text.Perl__invlist_intersection_maybe_complement_2nd .text.Perl__invlist_union_maybe_complement_2nd .text.Perl__new_invlist_C_array .text.Perl__invlist_populate_swatch .text.Perl_pregfree2 .text.Perl_reg_temp_copy .text.Perl_new_stackinfo .text.Perl_leave_scope .text.Perl_save_scalar .text.Perl_save_hints .text.Perl_save_aliased_sv .text.Perl_sv_del_backref .text.Perl_sv_free2 .text.S_curse .text.Perl_sv_clear .text.S_sv_unmagicext_flags .text.Perl_sv_upgrade .text.Perl_sv_force_normal_flags .text.Perl_sv_unref_flags .text.Perl_sv_setsv_flags .text.S_glob_assign_glob .text.Perl_sv_2pv_flags .text.Perl_sv_grow .text.Perl_gv_setref .text.Perl_sv_magic .text.Perl_sv_pos_b2u_flags .text.Perl_sv_magicext .text.Perl_sv_rvweaken .text.Perl_sv_add_backref .text.S_utf8_mg_pos_cache_update .text.Perl_newSVpvf .text.Perl_sv_setpvn .text.Perl_sv_vcatpvfn_flags .text.Perl_sv_pvn_force_flags .text.Perl_sv_catpvn_flags .text.Perl_sv_2nv_flags .text.Perl_newSVpvn_flags .text.Perl_sv_utf8_upgrade_flags_grow .text.Perl_sv_mortalcopy_flags .text.Perl_sv_2iv_flags .text.Perl_sv_2num .text.Perl_sv_len_utf8_nomg .text.S_sv_pos_u2b_cached .text.Perl_sv_2uv_flags .text.S_hextract .text.Perl_sv_setiv .text.Perl_sv_setpvf .text.Perl_sv_catpvf .text.S_sv_display .text.Perl_report_uninit .text.S_sv_2iuv_common .text.S_find_uninit_var .text.Perl_sv_insert_flags .text.Perl_sv_chop .text.Perl_newSVhek .text.Perl_varname .text.Perl_newSVsv .text.Perl_sv_usepvn_flags .text.Perl_newSVuv .text.Perl_sv_recode_to_utf8 .text.Perl_sv_reftype .text.Perl_sv_ref .text.Perl_sv_sethek .text.Perl_sv_setpv .text.Perl_sv_setnv .text.Perl_sv_newmortal .text.Perl_sv_2bool_flags .text.Perl_sv_kill_backrefs .text.Perl_sv_replace .text.Perl_sv_eq_flags .text.Perl_sv_cmp_flags .text.Perl_newSVpvn_share .text.Perl_vnewSVpvf .text.Perl_sv_2cv .text.Perl_newSVrv .text.Perl_sv_bless .text.Perl_av_store .text.Perl_av_make .text.Perl_av_clear .text.Perl_av_delete .text.Perl_av_push .text.Perl_av_create_and_unshift_one .text.Perl_av_unshift .text.Perl_av_shift .text.Perl_io_close .text.Perl_do_print .text.Perl_cvgv_from_hek .text.S_gv_fetchmeth_internal .text.S_gv_stashsvpvn_cached .text.Perl_pv_escape .text.Perl_hv_iternext_flags .text.Perl_hv_copy_hints_hv .text.Perl_hv_clear .text.Perl_hfree_next_entry .text.Perl_hv_undef_flags .text.Perl_hv_name_set .text.Perl_share_hek .text.Perl_gv_fetchfile_flags .text.Perl_gv_init_pvn .text.Perl_newGP .text.Perl_gv_name_set .text.Perl_cvgv_set .text.Perl_cop_store_label .text.Perl_keyword .text.Perl_mg_get .text.S_maybe_add_coresub .text.Perl_gv_fetchpvn_flags .text.S_gv_init_svtype .text.S_require_tie_mod .text.Perl_gv_fetchmethod_pvn_flags .text.Perl_gv_autoload_pvn .text.Perl_gv_fetchmeth_pvn_autoload .text.Perl_gv_fullname4 .text.Perl_gp_free .text.Perl_Gv_AMupdate .text.Perl_amagic_call .text.Perl_amagic_deref_call .text.Perl_gv_try_downgrade .text.Perl_hv_common .text.Perl_hv_free_ent .text.S_share_hek_flags .text.S_unshare_hek_or_pvn .text.S_clear_placeholders .text.S_hsplit .text.S_hv_auxinit .text.Perl_op_lvalue_flags .text.S_scalar_mod_type .text.Perl_doref .text.S_lvref .text.Perl_load_module .text.Perl_vload_module .text.Perl_utilize .text.Perl_op_convert_list .text.Perl_newSTATEOP .text.Perl_newATTRSUB_x .text.S_move_proto_attr .text.Perl_cv_ckproto_len_flags .text.S_scalarseq .text.S_already_defined .text.Perl_newCONSTSUB_flags .text.S_apply_attrs .text.S_process_special_blocks .text.Perl_newXS_len_flags .text.Perl_report_redefined_cv .text.Perl_newBINOP .text.Perl_hv_ename_add .text.Perl_hv_ename_delete .text.S_refcounted_he_value .text.Perl_refcounted_he_fetch_pvn .text.Perl_refcounted_he_new_pvn .text.Perl_newSLICEOP .text.S_new_logop .text.Perl_newCONDOP .text.Perl_newSTUB .text.S_restore_magic .text.Perl_mg_set .text.Perl_mg_size .text.Perl_mg_clear .text.Perl_mg_copy .text.Perl_mg_localize .text.Perl_mg_free .text.Perl_magic_clearisa .text.Perl_magic_methcall .text.S_magic_methcall1 .text.Perl_magic_nextpack .text.Perl_pad_tidy .text.Perl_cv_name .text.Perl_pad_fixup_inner_anons .text.Perl_grok_bin .text.Perl_grok_hex .text.Perl_grok_infnan .text.Perl_grok_number_flags .text.Perl_my_atof2 .text.Perl_isinfnansv .text.Perl_opslab_free_nopad .text.Perl_op_free .text.S_find_and_forget_pmops .text.Perl_op_clear .text.S_op_clear_gv .text.Perl_newSVOP .text.Perl_newUNOP .text.Perl_newOP .text.Perl_newLISTOP .text.Perl_op_sibling_splice .text.Perl_scalar .text.S_fold_constants .text.Perl_op_linklist .text.Perl_scalarvoid .text.Perl_custom_op_get_field .text.Perl_list .text.S_check_hash_fields_and_hekify .text.S_finalize_op .text.S_scalar_slice_warning .text.Perl_PerlIO_stderr .text.PerlIO_vprintf .text.PerlIO_printf .text.Perl_core_prototype .text.Perl_coresub_op .text.Perl_pad_new .text.Perl_padname_free .text.Perl_cv_undef_flags .text.Perl_pad_add_weakref .text.Perl_call_list .text.Perl_call_sv .text.S_my_exit_jump .text.Perl_my_exit .text.Perl_call_method .text.Perl_eval_sv .text.Perl_require_pv .text.Perl_my_failure_exit .text.PerlIO_push .text.PerlIO_default_layers .text.PerlIO_clone_list .text.PerlIO_find_layer .text.PerlIO_parse_layers .text.PerlIO_openn .text.PerlIO_apply_layers .text.PerlIO_resolve_layers .text.Perl_PerlIO_write .text.Perl_utf8_hop .text.Perl_bytes_cmp_utf8 .text.S_is_utf8_common .text.Perl__core_swash_init .text.Perl_swash_fetch .text.S_swatch_get .text.S_swash_scan_list_line .text.Perl__swash_to_invlist .text.Perl_check_utf8_print .text.Perl_pv_uni_display .text.Perl_safesysmalloc .text.Perl_safesysrealloc .text.Perl_safesyscalloc .text.Perl_croak .text.Perl_vcroak .text.Perl_mess_sv .text.S_invoke_exception_hook .text.Perl_closest_cop .text.Perl_form .text.Perl_mess .text.Perl_vmess .text.Perl_write_to_stderr .text.Perl_die .text.Perl_croak_popstack .text.Perl_warn .text.Perl_ck_warner_d .text.Perl_vwarner .text.Perl_ck_warner .text.Perl_warner .text.Perl_my_pclose .text.Perl_prescan_version .text.Perl_scan_version .text.Perl_new_version .text.Perl_upg_version .text.Perl_my_snprintf .text.Perl_vnumify .text.Perl_vcmp .text.Perl_mro_get_linear_isa .text.Perl_mro_isa_changed_in .text.S_mro_clean_isarev .text.Perl_mro_package_moved .text.S_mro_gather_and_rename .text.Perl_mro_method_changed_in .text.Perl_pp_anonlist .text.Perl_dounwind .text.Perl_qerror .text.Perl_die_unwind .text.Perl_delete_eval_scope .text.Perl_create_eval_scope .text.Perl__add_range_to_invlist .text.Perl_save_re_context .text.S__append_range_to_invlist)
. = ALIGN(0x1000);
*(.text.Perl_Slab_Alloc)
. = ALIGN(0x1000);
*(.text.*)
/* .gnu.warning sections are handled specially by elf32.em.  */
*(.gnu.warning)
}
.fini ALIGN(0x1000):
{
KEEP (*(SORT_NONE(.fini)))
}
PROVIDE (__etext = .);
PROVIDE (_etext = .);
PROVIDE (etext = .);
.rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) }
.rodata1        : { *(.rodata1) }
.eh_frame_hdr : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) }
.eh_frame       : ONLY_IF_RO { KEEP (*(.eh_frame)) *(.eh_frame.*) }
.gcc_except_table   : ONLY_IF_RO { *(.gcc_except_table
.gcc_except_table.*) }
.gnu_extab   : ONLY_IF_RO { *(.gnu_extab*) }
/* These sections are generated by the Sun/Oracle C++ compiler.  */
.exception_ranges   : ONLY_IF_RO { *(.exception_ranges
.exception_ranges*) }
/* Adjust the address for the data segment.  We want to adjust up to
the same address within the page on the next page up.  */
. = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));
/* Exception handling  */
.eh_frame       : ONLY_IF_RW { KEEP (*(.eh_frame)) *(.eh_frame.*) }
.gnu_extab      : ONLY_IF_RW { *(.gnu_extab) }
.gcc_except_table   : ONLY_IF_RW { *(.gcc_except_table .gcc_except_table.*) }
.exception_ranges   : ONLY_IF_RW { *(.exception_ranges .exception_ranges*) }
/* Thread Local Storage sections  */
.tdata	  : { *(.tdata .tdata.* .gnu.linkonce.td.*) }
.tbss		  : { *(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon) }
.preinit_array     :
{
PROVIDE_HIDDEN (__preinit_array_start = .);
KEEP (*(.preinit_array))
PROVIDE_HIDDEN (__preinit_array_end = .);
}
.init_array     :
{
PROVIDE_HIDDEN (__init_array_start = .);
KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
PROVIDE_HIDDEN (__init_array_end = .);
}
.fini_array     :
{
PROVIDE_HIDDEN (__fini_array_start = .);
KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
PROVIDE_HIDDEN (__fini_array_end = .);
}
.ctors          :
{
/* gcc uses crtbegin.o to find the start of
the constructors, so we make sure it is
first.  Because this is a wildcard, it
doesn't matter if the user does not
actually link against crtbegin.o; the
linker won't look for a file to match a
wildcard.  The wildcard also means that it
doesn't matter which directory crtbegin.o
is in.  */
KEEP (*crtbegin.o(.ctors))
KEEP (*crtbegin?.o(.ctors))
/* We don't want to include the .ctor section from
the crtend.o file until after the sorted ctors.
The .ctor section from the crtend file contains the
end of ctors marker and it must be last */
KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
KEEP (*(SORT(.ctors.*)))
KEEP (*(.ctors))
}
.dtors          :
{
KEEP (*crtbegin.o(.dtors))
KEEP (*crtbegin?.o(.dtors))
KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
KEEP (*(SORT(.dtors.*)))
KEEP (*(.dtors))
}
.jcr            : { KEEP (*(.jcr)) }
.data.rel.ro : { *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*) }
.dynamic        : { *(.dynamic) }
.got            : { *(.got.plt) *(.igot.plt) *(.got) *(.igot) }
. = DATA_SEGMENT_RELRO_END (0, .);
.data           :
{
*(.data .data.* .gnu.linkonce.d.*)
SORT(CONSTRUCTORS)
}
.data1          : { *(.data1) }
_edata = .; PROVIDE (edata = .);
. = .;
__bss_start = .;
.bss            :
{
*(.dynbss)
*(.bss .bss.* .gnu.linkonce.b.*)
*(COMMON)
/* Align here to ensure that the .bss section occupies space up to
_end.  Align after .bss to ensure correct alignment even if the
.bss section disappears because there are no input sections.
FIXME: Why do we need it? When there is no .bss section, we don't
pad the .data section.  */
. = ALIGN(. != 0 ? 64 / 8 : 1);
}
.lbss   :
{
*(.dynlbss)
*(.lbss .lbss.* .gnu.linkonce.lb.*)
*(LARGE_COMMON)
}
. = ALIGN(64 / 8);
. = SEGMENT_START("ldata-segment", .);
.lrodata   ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1)) :
{
*(.lrodata .lrodata.* .gnu.linkonce.lr.*)
}
.ldata   ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1)) :
{
*(.ldata .ldata.* .gnu.linkonce.l.*)
. = ALIGN(. != 0 ? 64 / 8 : 1);
}
. = ALIGN(64 / 8);
_end = .; PROVIDE (end = .);
. = DATA_SEGMENT_END (.);
/* Stabs debugging sections.  */
.stab          0 : { *(.stab) }
.stabstr       0 : { *(.stabstr) }
.stab.excl     0 : { *(.stab.excl) }
.stab.exclstr  0 : { *(.stab.exclstr) }
.stab.index    0 : { *(.stab.index) }
.stab.indexstr 0 : { *(.stab.indexstr) }
.comment       0 : { *(.comment) }
/* DWARF debug sections.
Symbols in the DWARF debugging sections are relative to the beginning
of the section so we begin them at 0.  */
/* DWARF 1 */
.debug          0 : { *(.debug) }
.line           0 : { *(.line) }
/* GNU DWARF 1 extensions */
.debug_srcinfo  0 : { *(.debug_srcinfo) }
.debug_sfnames  0 : { *(.debug_sfnames) }
/* DWARF 1.1 and DWARF 2 */
.debug_aranges  0 : { *(.debug_aranges) }
.debug_pubnames 0 : { *(.debug_pubnames) }
/* DWARF 2 */
.debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
.debug_abbrev   0 : { *(.debug_abbrev) }
.debug_line     0 : { *(.debug_line .debug_line.* .debug_line_end ) }
.debug_frame    0 : { *(.debug_frame) }
.debug_str      0 : { *(.debug_str) }
.debug_loc      0 : { *(.debug_loc) }
.debug_macinfo  0 : { *(.debug_macinfo) }
/* SGI/MIPS DWARF 2 extensions */
.debug_weaknames 0 : { *(.debug_weaknames) }
.debug_funcnames 0 : { *(.debug_funcnames) }
.debug_typenames 0 : { *(.debug_typenames) }
.debug_varnames  0 : { *(.debug_varnames) }
/* DWARF 3 */
.debug_pubtypes 0 : { *(.debug_pubtypes) }
.debug_ranges   0 : { *(.debug_ranges) }
/* DWARF Extension.  */
.debug_macro    0 : { *(.debug_macro) }
.debug_addr     0 : { *(.debug_addr) }
.gnu.attributes 0 : { KEEP (*(.gnu.attributes)) }
/DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) *(.gnu.lto_*) }
}
