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
*(.text.x264_cqm_delete)
. = ALIGN(0x1000);
*(.text.x264_slurp_file)
. = ALIGN(0x1000);
*(.text.x264_cqm_parse_jmlist)
. = ALIGN(0x1000);
*(.text.find_underflow)
. = ALIGN(0x1000);
*(.text.x264_param_parse .text.x264_atobool)
. = ALIGN(0x1000);
*(.text.x264_macroblock_thread_allocate)
. = ALIGN(0x1000);
*(.text.x264_cqm_parse_file)
. = ALIGN(0x1000);
*(.text.x264_pps_init)
. = ALIGN(0x1000);
*(.text.x264_cqm_init)
. = ALIGN(0x1000);
*(.text.x264_rdo_init)
. = ALIGN(0x1000);
*(.text.x264_init_vlc_tables)
. = ALIGN(0x1000);
*(.text.x264_analyse_init_costs)
. = ALIGN(0x1000);
*(.text.x264_lookahead_init)
. = ALIGN(0x1000);
*(.text.x264_ratecontrol_new)
. = ALIGN(0x1000);
*(.text.x264_macroblock_thread_free)
. = ALIGN(0x1000);
*(.text.x264_frame_delete)
. = ALIGN(0x1000);
*(.text.x264_lookahead_delete)
. = ALIGN(0x1000);
*(.text.x264_ratecontrol_delete)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_allocate)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_free)
. = ALIGN(0x1000);
*(.text.refine_subpel)
. = ALIGN(0x1000);
*(.text.x264_mb_mc_8x8 .text.x264_mb_mc_0xywh .text.x264_mb_mc_01xywh .text.x264_mb_mc_1xywh .text.x264_mb_mc .text.x264_me_refine_bidir .text.x264_mb_encode_i4x4 .text.x264_mb_encode_i8x8 .text.x264_mb_encode_8x8_chroma .text.x264_macroblock_encode .text.x264_macroblock_encode_p8x8 .text.x264_macroblock_encode_p4x4 .text.x264_mb_predict_mv .text.x264_rd_cost_part .text.x264_rd_cost_mb .text.ssd_plane .text.block_residual_write_cabac_internal .text.x264_cabac_mb_mvd_cpn .text.block_residual_write_cavlc .text.x264_cabac_mb8x8_mvd .text.cavlc_mb8x8_mvd .text.x264_macroblock_luma_write_cavlc .text.x264_macroblock_size_cabac)
. = ALIGN(0x1000);
*(.text.x264_cabac_encode_decision_c)
. = ALIGN(0x1000);
*(.text.x264_mb_predict_mv_16x16)
. = ALIGN(0x1000);
*(.text.quant_trellis_cabac)
. = ALIGN(0x1000);
*(.text.clip_qscale)
. = ALIGN(0x1000);
*(.text.x264_ratecontrol_init_reconfigurable)
. = ALIGN(0x1000);
*(.text.x264_frame_new)
. = ALIGN(0x1000);
*(.text.x264_validate_parameters)
. = ALIGN(0x1000);
*(.text.x264_set_aspect_ratio)
. = ALIGN(0x1000);
*(.text.x264_sps_init)
. = ALIGN(0x1000);
*(.text.x264_validate_levels)
. = ALIGN(0x1000);
*(.text.x264_sps_write)
. = ALIGN(0x1000);
*(.text.x264_pps_write .text.scaling_list_write)
. = ALIGN(0x1000);
*(.text.x264_sei_version_write)
. = ALIGN(0x1000);
*(.text.x264_param2string)
. = ALIGN(0x1000);
*(.text.x264_encoder_encapsulate_nals)
. = ALIGN(0x1000);
*(.text.x264_thread_sync_ratecontrol)
. = ALIGN(0x1000);
*(.text.x264_frame_init_lowres .text.x264_pixel_ssd_wxh .text.x264_pixel_ssim_wxh .text.x264_frame_filter .text.x264_macroblock_slice_init .text.x264_macroblock_cache_load .text.x264_macroblock_load_pic_pointers .text.x264_macroblock_cache_load_deblock .text.x264_macroblock_cache_save .text.x264_macroblock_bipred_init .text.x264_frame_copy_picture .text.x264_frame_expand_border .text.x264_frame_expand_border_filtered .text.x264_frame_expand_border_lowres .text.x264_frame_expand_border_mod16 .text.x264_slicetype_frame_cost .text.x264_slicetype_mb_cost .text.x264_slicetype_analyse .text.scenecut .text.scenecut_internal .text.x264_macroblock_tree_propagate .text.x264_slicetype_frame_cost_recalculate .text.x264_slicetype_decide .text.x264_rc_analyse_slice .text.x264_me_search_ref .text.x264_me_refine_qpel_rd .text.x264_adaptive_quant_frame .text.x264_macroblock_tree_read .text.x264_reference_build_list_optimal .text.x264_sei_recovery_point_write .text.x264_sei_buffering_period_write .text.x264_sei_pic_timing_write .text.x264_filler_write .text.x264_macroblock_probe_skip .text.x264_noise_reduction_update .text.x264_macroblock_write_cabac .text.x264_cabac_mb_type_intra .text.x264_cabac_mb_mvd_cpn.452 .text.x264_cabac_encode_ue_bypass .text.x264_cabac_encode_flush .text.x264_frame_deblock_row .text.x264_mb_predict_mv_direct16x16 .text.x264_mb_predict_mv_ref16x16 .text.x264_analyse_weight_frame .text.x264_macroblock_analyse .text.x264_mb_analyse_intra .text.x264_intra_rd .text.x264_intra_rd_refine .text.x264_analyse_update_cache .text.x264_mb_analyse_inter_p4x4_chroma .text.x264_mb_cache_mv_p8x8 .text.x264_mb_analyse_intra_chroma .text.x264_mb_analyse_b_rd .text.x264_mb_cache_mv_b8x8 .text.x264_mb_analyse_inter_b16x8 .text.x264_rd_cost_i8x8_chroma .text.x264_weights_analyse .text.x264_ratecontrol_start .text.rate_estimate_qscale .text.x264_ratecontrol_mb .text.predict_row_size_sum .text.x264_ratecontrol_slice_type .text.x264_ratecontrol_end .text.x264_threads_distribute_ratecontrol .text.x264_threads_merge_ratecontrol .text.block_residual_write_cabac .text.x264_macroblock_write_cavlc .text.block_residual_write_cavlc.482 .text.block_residual_write_cavlc_escape .text.x264_encoder_reconfig .text.x264_encoder_encode .text.x264_encoder_frame_end .text.x264_reference_hierarchy_reset .text.x264_slice_header_init .text.x264_fdec_filter_row .text.x264_lookahead_get_frames)
. = ALIGN(0x1000);
*(.text.x264_param_default_preset)
. = ALIGN(0x1000);
*(.text.Help)
. = ALIGN(0x1000);
*(.text.x264_param_apply_profile)
. = ALIGN(0x1000);
*(.text.open_file.611)
. = ALIGN(0x1000);
*(.text.x264_encoder_open_96)
. = ALIGN(0x1000);
*(.text.x264_encoder_headers)
. = ALIGN(0x1000);
*(.text.x264_encoder_close)
. = ALIGN(0x1000);
*(.text.x264_plane_copy_c)
. = ALIGN(0x1000);
*(.text.mc_luma)
. = ALIGN(0x1000);
*(.text.get_ref)
. = ALIGN(0x1000);
*(.text.sub8x8_dct)
. = ALIGN(0x1000);
*(.text.sub8x8_dct_dc)
. = ALIGN(0x1000);
*(.text.add8x8_idct)
. = ALIGN(0x1000);
*(.text.add8x8_idct_dc)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_8x16)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_1_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_2_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_4_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_2_4)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_4_4)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_1_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_2_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_1_2)
. = ALIGN(0x1000);
*(.text.predict_4x4_dc)
. = ALIGN(0x1000);
*(.text.predict_4x4_ddl)
. = ALIGN(0x1000);
*(.text.predict_4x4_ddr)
. = ALIGN(0x1000);
*(.text.predict_4x4_vr)
. = ALIGN(0x1000);
*(.text.predict_4x4_hd)
. = ALIGN(0x1000);
*(.text.predict_4x4_vl)
. = ALIGN(0x1000);
*(.text.predict_4x4_hu)
. = ALIGN(0x1000);
*(.text.predict_4x4_dc_left)
. = ALIGN(0x1000);
*(.text.predict_4x4_dc_top)
. = ALIGN(0x1000);
*(.text.predict_4x4_dc_128)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x3_16x8)
. = ALIGN(0x1000);
*(.text.mc_chroma)
. = ALIGN(0x1000);
*(.text.pixel_avg_16x16)
. = ALIGN(0x1000);
*(.text.pixel_avg_16x8)
. = ALIGN(0x1000);
*(.text.pixel_avg_8x16)
. = ALIGN(0x1000);
*(.text.mc_copy_w16)
. = ALIGN(0x1000);
*(.text.pixel_avg_8x8)
. = ALIGN(0x1000);
*(.text.pixel_avg_8x4)
. = ALIGN(0x1000);
*(.text.pixel_avg_weight_wxh)
. = ALIGN(0x1000);
*(.text.pixel_avg_4x8)
. = ALIGN(0x1000);
*(.text.pixel_avg_4x4)
. = ALIGN(0x1000);
*(.text.pixel_avg_4x2)
. = ALIGN(0x1000);
*(.text.pixel_avg_2x4)
. = ALIGN(0x1000);
*(.text.pixel_avg_2x2)
. = ALIGN(0x1000);
*(.text.x264_weight_cache)
. = ALIGN(0x1000);
*(.text.mc_copy_w8)
. = ALIGN(0x1000);
*(.text.mc_copy_w4)
. = ALIGN(0x1000);
*(.text.hpel_filter)
. = ALIGN(0x1000);
*(.text.prefetch_fenc_null)
. = ALIGN(0x1000);
*(.text.prefetch_ref_null)
. = ALIGN(0x1000);
*(.text.memzero_aligned)
. = ALIGN(0x1000);
*(.text.frame_init_lowres_core)
. = ALIGN(0x1000);
*(.text.integral_init4h)
. = ALIGN(0x1000);
*(.text.integral_init8h)
. = ALIGN(0x1000);
*(.text.integral_init4v)
. = ALIGN(0x1000);
*(.text.integral_init8v)
. = ALIGN(0x1000);
*(.text.mbtree_propagate_cost)
. = ALIGN(0x1000);
*(.text.mc_weight_w2)
. = ALIGN(0x1000);
*(.text.mc_weight_w4)
. = ALIGN(0x1000);
*(.text.mc_weight_w8)
. = ALIGN(0x1000);
*(.text.mc_weight_w12)
. = ALIGN(0x1000);
*(.text.mc_weight_w16)
. = ALIGN(0x1000);
*(.text.mc_weight_w20)
. = ALIGN(0x1000);
*(.text.predict_16x16_v)
. = ALIGN(0x1000);
*(.text.predict_16x16_h)
. = ALIGN(0x1000);
*(.text.predict_16x16_dc)
. = ALIGN(0x1000);
*(.text.predict_16x16_p)
. = ALIGN(0x1000);
*(.text.predict_16x16_dc_left)
. = ALIGN(0x1000);
*(.text.predict_16x16_dc_top)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x3_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_8x16)
. = ALIGN(0x1000);
*(.text.predict_16x16_dc_128)
. = ALIGN(0x1000);
*(.text.predict_8x8c_v)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_sad_x4_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_ssd_8x8)
. = ALIGN(0x1000);
*(.text.predict_8x8c_h)
. = ALIGN(0x1000);
*(.text.predict_8x8c_dc)
. = ALIGN(0x1000);
*(.text.predict_8x8c_p)
. = ALIGN(0x1000);
*(.text.predict_8x8c_dc_left)
. = ALIGN(0x1000);
*(.text.predict_8x8c_dc_top)
. = ALIGN(0x1000);
*(.text.predict_8x8c_dc_128)
. = ALIGN(0x1000);
*(.text.predict_8x8_v)
. = ALIGN(0x1000);
*(.text.predict_8x8_h)
. = ALIGN(0x1000);
*(.text.predict_8x8_dc)
. = ALIGN(0x1000);
*(.text.predict_8x8_ddl)
. = ALIGN(0x1000);
*(.text.predict_8x8_ddr)
. = ALIGN(0x1000);
*(.text.predict_8x8_vr)
. = ALIGN(0x1000);
*(.text.predict_8x8_hd)
. = ALIGN(0x1000);
*(.text.predict_8x8_vl)
. = ALIGN(0x1000);
*(.text.predict_8x8_hu)
. = ALIGN(0x1000);
*(.text.predict_8x8_dc_left)
. = ALIGN(0x1000);
*(.text.predict_8x8_dc_top)
. = ALIGN(0x1000);
*(.text.predict_8x8_dc_128)
. = ALIGN(0x1000);
*(.text.predict_8x8_filter)
. = ALIGN(0x1000);
*(.text.predict_4x4_v)
. = ALIGN(0x1000);
*(.text.predict_4x4_h)
. = ALIGN(0x1000);
*(.text.sub16x16_dct)
. = ALIGN(0x1000);
*(.text.sub4x4_dct)
. = ALIGN(0x1000);
*(.text.add16x16_idct)
. = ALIGN(0x1000);
*(.text.add4x4_idct)
. = ALIGN(0x1000);
*(.text.add16x16_idct_dc)
. = ALIGN(0x1000);
*(.text.add4x4_idct_dc)
. = ALIGN(0x1000);
*(.text.sub16x16_dct8)
. = ALIGN(0x1000);
*(.text.sub8x8_dct8)
. = ALIGN(0x1000);
*(.text.add16x16_idct8)
. = ALIGN(0x1000);
*(.text.add8x8_idct8)
. = ALIGN(0x1000);
*(.text.dct4x4dc)
. = ALIGN(0x1000);
*(.text.idct4x4dc)
. = ALIGN(0x1000);
*(.text.zigzag_scan_8x8_frame)
. = ALIGN(0x1000);
*(.text.zigzag_scan_8x8_field)
. = ALIGN(0x1000);
*(.text.zigzag_scan_4x4_frame)
. = ALIGN(0x1000);
*(.text.zigzag_scan_4x4_field)
. = ALIGN(0x1000);
*(.text.zigzag_sub_8x8_frame)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_8x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_4x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_x4_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_satd_4x4)
. = ALIGN(0x1000);
*(.text.x264_pixel_hadamard_ac_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_hadamard_ac_16x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_hadamard_ac_8x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_hadamard_ac_8x8)
. = ALIGN(0x1000);
*(.text.pixel_hadamard_ac)
. = ALIGN(0x1000);
*(.text.x264_pixel_ads4)
. = ALIGN(0x1000);
*(.text.x264_pixel_ads2)
. = ALIGN(0x1000);
*(.text.x264_pixel_ads1)
. = ALIGN(0x1000);
*(.text.x264_pixel_sa8d_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_sa8d_8x8)
. = ALIGN(0x1000);
*(.text.sa8d_8x8)
. = ALIGN(0x1000);
*(.text.x264_pixel_var_16x16)
. = ALIGN(0x1000);
*(.text.x264_pixel_var_8x8)
. = ALIGN(0x1000);
*(.text.ssim_4x4x2_core)
. = ALIGN(0x1000);
*(.text.ssim_end4)
. = ALIGN(0x1000);
*(.text.pixel_var2_8x8)
. = ALIGN(0x1000);
*(.text.zigzag_sub_8x8_field)
. = ALIGN(0x1000);
*(.text.zigzag_sub_4x4_frame)
. = ALIGN(0x1000);
*(.text.zigzag_sub_4x4_field)
. = ALIGN(0x1000);
*(.text.zigzag_sub_4x4ac_frame)
. = ALIGN(0x1000);
*(.text.zigzag_sub_4x4ac_field)
. = ALIGN(0x1000);
*(.text.zigzag_interleave_8x8_cavlc)
. = ALIGN(0x1000);
*(.text.x264_log_default)
. = ALIGN(0x1000);
*(.text.x264_picture_alloc)
. = ALIGN(0x1000);
*(.text.x264_log)
. = ALIGN(0x1000);
*(.text.x264_picture_clean)
. = ALIGN(0x1000);
*(.text.x264_free)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_1_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_2_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_1_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_2_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_4_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_2_4)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mv_4_4)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_1_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_mvd_2_1)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_2_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_4_2)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_2_4)
. = ALIGN(0x1000);
*(.text.x264_macroblock_cache_ref_4_4)
. = ALIGN(0x1000);
*(.text.quant_8x8)
. = ALIGN(0x1000);
*(.text.quant_4x4)
. = ALIGN(0x1000);
*(.text.quant_4x4_dc)
. = ALIGN(0x1000);
*(.text.quant_2x2_dc)
. = ALIGN(0x1000);
*(.text.dequant_4x4)
. = ALIGN(0x1000);
*(.text.dequant_4x4_dc)
. = ALIGN(0x1000);
*(.text.dequant_8x8)
. = ALIGN(0x1000);
*(.text.x264_denoise_dct)
. = ALIGN(0x1000);
*(.text.x264_decimate_score15)
. = ALIGN(0x1000);
*(.text.x264_decimate_score16)
. = ALIGN(0x1000);
*(.text.x264_decimate_score64)
. = ALIGN(0x1000);
*(.text.x264_coeff_last4)
. = ALIGN(0x1000);
*(.text.x264_coeff_last15)
. = ALIGN(0x1000);
*(.text.x264_coeff_last16)
. = ALIGN(0x1000);
*(.text.x264_coeff_last64)
. = ALIGN(0x1000);
*(.text.x264_coeff_level_run4)
. = ALIGN(0x1000);
*(.text.x264_coeff_level_run15)
. = ALIGN(0x1000);
*(.text.x264_coeff_level_run16)
. = ALIGN(0x1000);
*(.text.deblock_v_luma_c)
. = ALIGN(0x1000);
*(.text.deblock_h_luma_c)
. = ALIGN(0x1000);
*(.text.deblock_luma_c)
. = ALIGN(0x1000);
*(.text.deblock_v_chroma_c)
. = ALIGN(0x1000);
*(.text.deblock_h_chroma_c)
. = ALIGN(0x1000);
*(.text.deblock_chroma_c)
. = ALIGN(0x1000);
*(.text.deblock_v_luma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_h_luma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_luma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_v_chroma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_h_chroma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_chroma_intra_c)
. = ALIGN(0x1000);
*(.text.deblock_strength_c)
. = ALIGN(0x1000);
*(.text.open_file)
. = ALIGN(0x1000);
*(.text.get_frame_total)
. = ALIGN(0x1000);
*(.text.read_frame)
. = ALIGN(0x1000);
*(.text.release_frame)
. = ALIGN(0x1000);
*(.text.close_file)
. = ALIGN(0x1000);
*(.text.get_frame_total.612)
. = ALIGN(0x1000);
*(.text.read_frame.613)
. = ALIGN(0x1000);
*(.text.close_file.614)
. = ALIGN(0x1000);
*(.text.open_file.619)
. = ALIGN(0x1000);
*(.text.get_frame_total.620)
. = ALIGN(0x1000);
*(.text.read_frame.621)
. = ALIGN(0x1000);
*(.text.close_file.622)
. = ALIGN(0x1000);
*(.text.open_file.633)
. = ALIGN(0x1000);
*(.text.set_param)
. = ALIGN(0x1000);
*(.text.write_headers)
. = ALIGN(0x1000);
*(.text.write_frame)
. = ALIGN(0x1000);
*(.text.close_file.634)
. = ALIGN(0x1000);
*(.text.open_file.637 .text.mk_create_writer)
. = ALIGN(0x1000);
*(.text.set_param.638)
. = ALIGN(0x1000);
*(.text.write_headers.639 .text.mk_writeHeader)
. = ALIGN(0x1000);
*(.text.write_frame.640)
. = ALIGN(0x1000);
*(.text.mk_add_frame_data)
. = ALIGN(0x1000);
*(.text.close_file.641 .text.mk_close)
. = ALIGN(0x1000);
*(.text.mk_write_size .text.mk_write_uint .text.mk_flush_frame .text.mk_close_cluster)
. = ALIGN(0x1000);
*(.text.open_file.659)
. = ALIGN(0x1000);
*(.text.set_param.660 .text.x264_put_amf_string)
. = ALIGN(0x1000);
*(.text.write_headers.661)
. = ALIGN(0x1000);
*(.text.write_frame.662)
. = ALIGN(0x1000);
*(.text.x264_put_be24)
. = ALIGN(0x1000);
*(.text.x264_put_be32)
. = ALIGN(0x1000);
*(.text.close_file.663)
. = ALIGN(0x1000);
*(.text.open_file.702)
. = ALIGN(0x1000);
*(.text.get_frame_total.703)
. = ALIGN(0x1000);
*(.text.read_frame.704)
. = ALIGN(0x1000);
*(.text.release_frame.705)
. = ALIGN(0x1000);
*(.text.close_file.706)
. = ALIGN(0x1000);
*(.text.SigIntHandler)
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
