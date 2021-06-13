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
*(.text._ZN9GameState18set_fixed_handicapEi)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard17predict_solid_eyeEiii)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard17get_string_stonesEi)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard13augment_chainERSt6vectorIiSaIiEEi)
. = ALIGN(0x1000);
*(.text._ZSt11__make_heapIN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEENS0_5__ops15_Iter_less_iterEEvT_S9_RT0_ .text._ZSt16__introsort_loopIN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEElNS0_5__ops15_Iter_less_iterEEvT_S9_T0_T1_)
. = ALIGN(0x1000);
*(.text._ZSt22__final_insertion_sortIN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEENS0_5__ops15_Iter_less_iterEEvT_S9_T0_)
. = ALIGN(0x1000);
*(.text._ZN7KoStateaSEOS_)
. = ALIGN(0x1000);
*(.text._ZN7Zobrist12init_zobristER6Random)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard11remove_deadEv)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard9run_bouzyEii)
. = ALIGN(0x1000);
*(.text._ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_)
. = ALIGN(0x1000);
*(.text._ZSt25__unguarded_linear_insertIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops14_Val_less_iterEEvT_T0_)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard10get_stringB5cxx11Ei .text._ZNSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESaIS5_EE17_M_realloc_insertIJS5_EEEvN9__gnu_cxx17__normal_iteratorIPS5_S7_EEDpOT_)
. = ALIGN(0x1000);
*(.text._ZSt16__introsort_loopIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEElNS0_5__ops15_Iter_less_iterEEvT_SF_T0_T1_ .text._ZSt11__make_heapIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops15_Iter_less_iterEEvT_SF_RT0_ .text._ZSt10__pop_heapIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops15_Iter_less_iterEEvT_SF_SF_RT0_ .text._ZSt22__move_median_to_firstIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops15_Iter_less_iterEEvT_SF_SF_SF_T0_ .text._ZSt21__unguarded_partitionIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops15_Iter_less_iterEET_SF_SF_SF_T0_ .text._ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEElS7_NS0_5__ops15_Iter_less_iterEEvT_T0_SG_T1_T2_ .text._ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEElS7_NS0_5__ops14_Iter_less_valEEvT_T0_SG_T1_RT2_)
. = ALIGN(0x1000);
*(.text._ZSt16__insertion_sortIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops15_Iter_less_iterEEvT_SF_T0_)
. = ALIGN(0x1000);
*(.text._ZSt8__uniqueIN9__gnu_cxx17__normal_iteratorIPNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt6vectorIS7_SaIS7_EEEENS0_5__ops19_Iter_equal_to_iterEET_SF_SF_T0_)
. = ALIGN(0x1000);
*(.text._ZNSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESaIS5_EE8_M_eraseEN9__gnu_cxx17__normal_iteratorIPS5_S7_EESB_)
. = ALIGN(0x1000);
*(.text._ZN5Utils10gtp_printfEiPKcz)
. = ALIGN(0x1000);
*(.text._ZN5Utils15gtp_fail_printfEiPKcz)
. = ALIGN(0x1000);
*(.text._ZN9GameState9init_gameEif)
. = ALIGN(0x1000);
*(.text._ZN7KoState10reset_gameEv .text._ZN9GameState10reset_gameEv)
. = ALIGN(0x1000);
*(.text._ZN9GameState13play_textmoveENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES5_)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard13display_boardEi)
. = ALIGN(0x1000);
*(.text._ZN11TimeControl13display_timesEv)
. = ALIGN(0x1000);
*(.text._ZSt4fillSt13_Bit_iteratorS_RKb)
. = ALIGN(0x1000);
*(.text._ZN3GTP13get_life_listB5cxx11ER9GameStateb)
. = ALIGN(0x1000);
*(.text._ZN7Playout20do_playout_benchmarkER9GameState)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard16calc_reach_colorEi .text._ZNSt6vectorIbSaIbEEC2EmRKbRKS0_ .text._ZNSt6vectorIbSaIbEEaSERKS1_)
. = ALIGN(0x1000);
*(.text._ZN9FastState9mark_deadEv)
. = ALIGN(0x1000);
*(.text._ZN7Playout3runER9FastStateb)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard10self_atariEii .text._ZN9FastBoard20add_string_libertiesILi3EEEviRN5boost5arrayIiXT_EEERi)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard15kill_neighboursEiRN5boost5arrayIiLm24EEERi .text._ZN9FastBoard24save_critical_neighboursEiiRN5boost5arrayIiLm24EEERi .text._ZN9FastBoard17add_pattern_movesEiiRN5boost5arrayIiLm24EEERi .text._ZN9FastBoard19add_global_capturesEiRN5boost5arrayIiLm24EEERi .text._ZN9FastState16play_random_moveEi .text._ZN9FastState15walk_empty_listEiib)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard17update_board_fastEii .text._ZN9FastBoard16update_board_eyeEii)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard10area_scoreEf)
. = ALIGN(0x1000);
*(.text._ZN9FastState11final_scoreEv)
. = ALIGN(0x1000);
*(.text._ZNSt20__uninitialized_copyILb0EE13__uninit_copyIN9__gnu_cxx17__normal_iteratorIPK7KoStateSt6vectorIS4_SaIS4_EEEEPS4_EET0_T_SD_SC_ .text._ZN9UCTSearch10dump_statsER9GameStateR7UCTNode .text._ZN9GameStateC2ERKS_ .text._ZN9UCTSearch6get_pvB5cxx11ER9GameStateR7UCTNode .text._ZN7UCTNode13sort_childrenEi .text._ZSt21__inplace_stable_sortIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEENS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_T0_ .text._ZSt22__stable_sort_adaptiveIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES9_lNS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_T0_T1_T2_ .text._ZSt24__merge_sort_with_bufferIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES9_NS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_T0_T1_ .text._ZSt16__merge_adaptiveIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEElS9_NS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_SI_T0_SJ_T1_SJ_T2_ .text._ZSt30__move_merge_adaptive_backwardIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES9_SD_NS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_T0_SJ_T1_T2_ .text._ZSt13__lower_boundIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES8_NS0_5__ops14_Iter_comp_valI8NodeCompEEET_SI_SI_RKT0_T1_ .text._ZSt17__rotate_adaptiveIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES9_lET_SE_SE_SE_T1_SF_T0_SF_ .text._ZNSt3_V28__rotateIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS4_9null_typeES8_S8_S8_S8_S8_S8_EESt6vectorIS9_SaIS9_EEEEEET_SF_SF_SF_St26random_access_iterator_tag .text._ZSt16__insertion_sortIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEENS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_T0_ .text._ZSt12__move_mergeIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEES9_NS0_5__ops15_Iter_comp_iterI8NodeCompEEET0_T_SJ_SJ_SJ_SI_T1_ .text._ZSt12__move_mergeIPN5boost6tuples5tupleIiiP7UCTNodeNS1_9null_typeES5_S5_S5_S5_S5_S5_EEN9__gnu_cxx17__normal_iteratorIS7_St6vectorIS6_SaIS6_EEEENS8_5__ops15_Iter_comp_iterI8NodeCompEEET0_T_SJ_SJ_SJ_SI_T1_ .text._ZSt22__merge_without_bufferIN9__gnu_cxx17__normal_iteratorIPN5boost6tuples5tupleIiiP7UCTNodeNS3_9null_typeES7_S7_S7_S7_S7_S7_EESt6vectorIS8_SaIS8_EEEElNS0_5__ops15_Iter_comp_iterI8NodeCompEEEvT_SI_SI_T0_SJ_T1_)
. = ALIGN(0x1000);
*(.text._ZN7Playout8mc_ownerER9FastStatei)
. = ALIGN(0x1000);
*(.text._ZN12MCOwnerTable5clearEv)
. = ALIGN(0x1000);
*(.text._ZN9UCTSearch15play_simulationER7KoStateP7UCTNode .text._ZN7UCTNode16uct_select_childEi .text._ZN7UCTNode15create_childrenER9FastStateb .text._ZN7UCTNode10updateRAVEER7Playouti)
. = ALIGN(0x1000);
*(.text._ZN7UCTNodeD2Ev)
. = ALIGN(0x1000);
*(.text._ZN9UCTSearch13get_best_moveEi .text._ZN9UCTSearch13dump_analysisEv .text._ZN9UCTSearch5thinkEii .text._ZN7UCTNode13kill_superkosER7KoState)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard12move_to_textB5cxx11Ei)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard10is_suicideEii)
. = ALIGN(0x1000);
*(.text._ZN5Utils8myprintfEPKcz)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard14get_stone_listB5cxx11Ev)
. = ALIGN(0x1000);
*(.text._ZN9GameState19place_free_handicapEi)
. = ALIGN(0x1000);
*(.text._ZN9FullBoard11reset_boardEi)
. = ALIGN(0x1000);
*(.text._ZN7KoState9init_gameEif)
. = ALIGN(0x1000);
*(.text._ZN9SGFParser14chop_from_fileENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi .text._ZN9SGFParser19parse_property_nameERNSt7__cxx1119basic_istringstreamIcSt11char_traitsIcESaIcEEE .text._ZN9SGFParser20parse_property_valueERNSt7__cxx1119basic_istringstreamIcSt11char_traitsIcESaIcEEERNS0_12basic_stringIcS3_S4_EE .text._ZN9SGFParser5parseERNSt7__cxx1119basic_istringstreamIcSt11char_traitsIcESaIcEEEP7SGFTree .text._ZN7SGFTreeC2ERKS_ .text._ZNSt8_Rb_treeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt4pairIKS5_S5_ESt10_Select1stIS8_ESt4lessIS5_ESaIS8_EE7_M_copyINSE_11_Alloc_nodeEEEPSt13_Rb_tree_nodeIS8_EPKSI_PSt18_Rb_tree_node_baseRT_ .text._ZNSt4pairIKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES5_EC2ERKS7_ .text._ZN7SGFTree16load_from_stringENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE .text._ZN7SGFTree15populate_statesEv .text._ZNSt8_Rb_treeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt4pairIKS5_S5_ESt10_Select1stIS8_ESt4lessIS5_ESaIS8_EE11equal_rangeERS7_ .text._ZN7SGFTree14load_from_fileENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi .text._ZN7SGFTree12add_propertyENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES5_ .text._ZNSt4pairINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES5_EC2IRS5_S8_Lb1EEEOT_OT0_ .text._ZNSt8_Rb_treeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt4pairIKS5_S5_ESt10_Select1stIS8_ESt4lessIS5_ESaIS8_EE16_M_emplace_equalIJS6_IS5_S5_EEEESt17_Rb_tree_iteratorIS8_EDpOT_ .text._ZN7SGFTree9add_childES_ .text._ZNSt6vectorI7SGFTreeSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_)
. = ALIGN(0x1000);
*(.text._ZN7SGFTree8get_moveEi)
. = ALIGN(0x1000);
*(.text._ZN7KoStateaSERKS_ .text._ZNSt6vectorIySaIyEEaSERKS1_)
. = ALIGN(0x1000);
*(.text._ZNSt6vectorIiSaIiEEaSERKS1_)
. = ALIGN(0x1000);
*(.text._ZN7KoState9play_moveEii)
. = ALIGN(0x1000);
*(.text._ZN7KoState9play_passEv)
. = ALIGN(0x1000);
*(.text._ZN9FullBoard12update_boardEii .text._ZN9FastState9play_moveEii)
. = ALIGN(0x1000);
*(.text._ZN7KoStateC2ERKS_)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard13merge_stringsEii)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard16remove_neighbourEii)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard13add_neighbourEii)
. = ALIGN(0x1000);
*(.text._ZNSt6vectorI7KoStateSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_)
. = ALIGN(0x1000);
*(.text._ZN9GameState9play_moveEii .text._ZNSt6vectorI7KoStateSaIS0_EE17_M_default_appendEm)
. = ALIGN(0x1000);
*(.text._ZN9GameStateD2Ev)
. = ALIGN(0x1000);
*(.text._ZN9GameState19anchor_game_historyEv)
. = ALIGN(0x1000);
*(.text._ZN7SGFTree12get_mainlineEj)
. = ALIGN(0x1000);
*(.text._ZNSt8_Rb_treeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEESt4pairIKS5_S5_ESt10_Select1stIS8_ESt4lessIS5_ESaIS8_EE8_M_eraseEPSt13_Rb_tree_nodeIS8_E .text._ZN7SGFTreeD2Ev)
. = ALIGN(0x1000);
*(.text.__clang_call_terminate)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_Leela.cpp)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_SGFParser.cpp)
. = ALIGN(0x1000);
*(.text._ZN9FastBoard11reset_boardEi)
. = ALIGN(0x1000);
*(.text._ZN7MatcherC2Ev .text._ZNSt6vectorIhSaIhEE6resizeEm .text._ZNSt8_Rb_treeIiSt4pairIKifESt10_Select1stIS2_ESt4lessIiESaIS2_EE17_M_emplace_uniqueIJRS0_IifEEEES0_ISt17_Rb_tree_iteratorIS2_EbEDpOT_ .text._ZNSt8_Rb_treeIiSt4pairIKifESt10_Select1stIS2_ESt4lessIiESaIS2_EE8_M_eraseEPSt13_Rb_tree_nodeIS2_E .text._ZN9FastBoard25get_pattern3_augment_specEiib)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_SGFTree.cpp)
. = ALIGN(0x1000);
*(.text._ZN7SGFTreeC2Ev)
. = ALIGN(0x1000);
*(.text._ZN9UCTSearchC2ER9GameState)
. = ALIGN(0x1000);
*(.text._ZN7PlayoutC2Ev)
. = ALIGN(0x1000);
*(.text._ZN11TimeControlC2Eiiii)
. = ALIGN(0x1000);
*(.text._ZN3SMP5MutexC2Ev)
. = ALIGN(0x1000);
*(.text._ZN3SMP4LockC2ERNS_5MutexE)
. = ALIGN(0x1000);
*(.text._ZN3SMP4LockD2Ev)
. = ALIGN(0x1000);
*(.text._ZN7UCTNodeC2Eii)
. = ALIGN(0x1000);
*(.text._ZN4TimeC2Ev)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_Utils.cpp)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_FastBoard.cpp)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_GTP.cpp)
. = ALIGN(0x1000);
*(.text.__cxx_global_array_dtor)
. = ALIGN(0x1000);
*(.text._ZN6TTableC2Ei)
. = ALIGN(0x1000);
*(.text._ZNSt6vectorI7TTEntrySaIS0_EE17_M_default_appendEm)
. = ALIGN(0x1000);
*(.text._ZN7TTEntryC2Ev)
. = ALIGN(0x1000);
*(.text._ZN12MCOwnerTableC2Ev)
. = ALIGN(0x1000);
*(.text._ZNSt6vectorIiSaIiEE17_M_default_appendEm)
. = ALIGN(0x1000);
*(.text._ZN6RandomC2Ei)
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
