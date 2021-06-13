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
*(.text._ZN3pov12ot_index_boxEPdS0_PNS_12ot_id_structE)
. = ALIGN(0x1000);
*(.text._ZN3pov22Do_Infinite_AtmosphereEPNS_10Ray_StructEPf .text._ZN3pov6ot_insEPPNS_14ot_node_structEPNS_15ot_block_structEPNS_12ot_id_structE .text._ZN3pov16ot_dist_traverseEPNS_14ot_node_structEPdiPFiPNS_15ot_block_structEPvES5_ .text._ZN3pov12ot_read_fileEPN8pov_base7IStreamE .text._ZN3pov5ParseEv .text._ZN3povL19Global_Setting_WarnEv .text._ZN3pov12Post_ProcessEPNS_13Object_StructES1_ .text._ZN3pov13Link_To_FrameEPNS_13Object_StructE .text._ZN3pov20Make_Pigment_EntriesEv .text._ZN3pov13Send_InitInfoEv .text._ZN3pov20Send_FrameStatisticsEv .text._ZN3pov20Send_ParseStatisticsEv .text._ZN3pov21Send_RenderStatisticsEb .text._ZN3pov18Send_RenderOptionsEv .text._ZN3pov18Send_RenderStartedEb .text._ZN3pov15Send_RenderDoneEb .text._Z16povray_cooperatev .text._ZN3pov25POVMSUtil_SetFormatStringEP9POVMSDatajPKcz .text._ZN3pov8do_phongEPNS_13Finish_StructEPNS_10Ray_StructEPdS4_PfS5_S5_ .text._ZN3pov16Initialize_NoiseEv .text._ZN3pov24Backtrace_Simulate_MediaEPPNS_12Media_StructEPNS_10Ray_StructEPNS_10istk_entryEPf .text._ZN3povL12sample_mediaEPNS_17Light_List_StructEiPNS_10Ray_StructEPPNS_12Media_StructEPNS_21Media_Interval_StructEidPfS9_iS1_i .text._ZN3povL22scattering_attenuationEPPNS_12Media_StructEPfS3_S3_PNS_10Ray_StructES5_ .text._ZN3pov14Simulate_MediaEPPNS_12Media_StructEPNS_10Ray_StructEPNS_10istk_entryEPfi .text._ZN3povL23update_light_list_entryEPNS_17Light_List_StructEPNS_10Ray_StructEPNS_10istk_entryE .text._ZN3povL16sample_media_recEPNS_17Light_List_StructEiPNS_10Ray_StructEPPNS_12Media_StructEPNS_21Media_Interval_StructEiddPfS9_S9_S9_S9_S9_iddS1_i .text._ZN3pov10Post_MediaEPNS_12Media_StructE .text._ZN3pov16Mesh_InterpolateEPdS0_PNS_11Mesh_StructEPNS_20Mesh_Triangle_StructE .text._ZN3pov14Perturb_NormalEPdPNS_14Tnormal_StructES0_PNS_10istk_entryE .text._ZN3pov20Do_Finite_AtmosphereEPNS_10Ray_StructEPNS_10istk_entryEPfi .text._ZN3pov20Initialize_BBox_CodeEv .text._ZN3pov15Build_BBox_TreeEPPNS_16BBox_Tree_StructElRS2_lS2_ .text._ZN3pov20Build_Bounding_SlabsEPPNS_16BBox_Tree_StructE .text._ZN3pov19Intersect_BBox_TreeEPNS_16BBox_Tree_StructEPNS_10Ray_StructEPNS_10istk_entryEPPNS_13Object_StructEb .text._ZN3pov23Determine_Blob_TexturesEPNS_11Blob_StructEPdPiPPNS_14Texture_StructES2_ .text._ZN3pov13Create_CameraEv .text._ZN3pov6chdtriEdd .text._ZN3povL4lgamEd .text._ZN3povL5igamcEdd .text._ZN3pov22Determine_CSG_TexturesEPNS_10CSG_StructEPdPiPPNS_14Texture_StructES2_ .text._ZN3povL17Find_CSG_TexturesEPNS_10CSG_StructEPdPiPPNS_14Texture_StructE .text._ZN3pov11do_specularEPNS_13Finish_StructEPNS_10Ray_StructEPdS4_PfS5_S5_ .text._ZN3povL7do_iridEPNS_13Finish_StructEPNS_10Ray_StructEPdS4_Pf .text._ZN3povL7ReflectEPdPNS_10Ray_StructES0_S0_Pfd .text._ZN3povL8do_lightEPNS_19Light_Source_StructEPdPNS_10Ray_StructES4_S2_Pf .text._ZN3povL18block_light_sourceEPNS_19Light_Source_StructEdPNS_10Ray_StructES3_PdPf .text._ZN3pov10do_diffuseEPNS_13Finish_StructEPNS_10Ray_StructEPdPfS5_S5_d .text._ZN3povL16block_area_lightEPNS_19Light_Source_StructEPdPNS_10Ray_StructES4_S2_Pfiiiii .text._ZN3povL17filter_shadow_rayEPNS_10istk_entryEPNS_10Ray_StructEPf .text._ZN3povL17block_point_lightEPNS_19Light_Source_StructEPdPNS_10Ray_StructEPf .text._ZN3pov11Test_ShadowEPNS_19Light_Source_StructEPdPNS_10Ray_StructES4_S2_Pf .text._ZN3pov11POVFPU_InitEv .text._ZN3pov16POVFPU_TerminateEv .text._ZN3pov23InitBacktraceEverythingEv .text._ZN3pov15BuildPhotonMapsEv .text._ZN3povL14AllocatePhotonEPNS_17photon_map_structE .text._ZN3povL16setGatherOptionsEPNS_17photon_map_structEi .text._ZN3povL20SearchThroughObjectsEPNS_13Object_StructEPNS_19Light_Source_StructEb .text._ZN3povL20ShootPhotonsAtObjectEPNS_13Object_StructEPNS_19Light_Source_StructEi .text._ZN3povL16sortAndSubdivideEiii .text._ZN3povL11halfSortRecEiiii .text._ZN3pov16addSurfacePhotonEPdS0_PfS0_ .text._ZN3pov14addMediaPhotonEPdS0_Pfd .text._ZN3pov9ChooseRayEPNS_10Ray_StructEPdS1_S2_i .text._ZN3pov15Attenuate_LightEPNS_19Light_Source_StructEPNS_10Ray_StructEd .text._ZN3pov15BuildRenderTimeEP9POVMSDatajiiii .text._ZN3pov21BuildRenderStatisticsEP9POVMSDataPx .text._ZN3pov14AddOIStatisticEP9POVMSDataiPx .text._ZN3pov8bump_mapEPdPNS_14Tnormal_StructES0_ .text._ZN3pov19Build_Light_BuffersEv .text._ZN3povL21project_bounding_slabEiPdPNS_14Project_StructEPPNS_24Project_Tree_Node_StructEPNS_16BBox_Tree_StructEiS2_ .text._ZN3povL14project_objectEPNS_14Project_StructEPNS_13Object_StructEiPdiS1_ .text._ZN3povL17project_rectangleEPNS_14Project_StructEPdS2_S2_S2_Pi .text._ZN3pov20Intersect_Light_TreeEPNS_10Ray_StructEPNS_24Project_Tree_Node_StructEiiPNS_10istk_entryEPPNS_13Object_StructEPNS_19Light_Source_StructE .text._ZN3pov24Initialize_Lighting_CodeEv .text._ZN3pov26Reinitialize_Lighting_CodeEiPPPNS_14Texture_StructEPPd .text._ZN3pov25Determine_Apparent_ColourEPNS_10istk_entryEPfPNS_10Ray_StructEd .text._ZN3pov22ResizeLightMallocPoolsEl .text._ZN3povL19create_texture_listEPNS_10istk_entryEd .text._ZN3povL14do_texture_mapEPfPNS_14Texture_StructEPdS3_PNS_10Ray_StructEdPNS_10istk_entryEi .text._ZN3povL25compute_backtrace_textureEPfPNS_14Texture_StructEPdS3_PNS_10Ray_StructEdPNS_10istk_entryE .text._ZN3pov22ResizeMediaMallocPoolsEl .text._ZN3povL23compute_lighted_textureEPfPNS_14Texture_StructEPdS3_PNS_10Ray_StructEdPNS_10istk_entryE .text._ZN3povL22determine_reflectivityEPdPfS1_S1_iddPNS_10Ray_StructEPNS_15Interior_StructE .text._ZN3povL17Diffuse_One_LightEPNS_19Light_Source_StructEiPdPNS_13Finish_StructES2_PNS_10Ray_StructES2_PfS7_dPNS_13Object_StructE .text._ZN3pov15Compute_AmbientEPdS0_S0_Pfd .text._ZN3pov25Initialize_Radiosity_CodeEv .text._ZN3pov19Copy_Ray_ContainersEPNS_10Ray_StructES1_ .text._ZN3pov8Ray_ExitEPNS_10Ray_StructEi .text._ZN3pov9FrameLoopEv .text._ZN3pov11FrameRenderEv .text._ZN3pov23fix_up_rendering_windowEv .text._ZN3pov23fix_up_animation_valuesEv .text._ZN3pov17fix_up_scene_nameEv .text._ZN3pov9init_varsEv .text._ZN3pov19Initialize_RendererEv .text._ZN3pov28Start_Tracing_Mosaic_PreviewEii .text._ZN3pov11trace_pixelEiiPfS0_ .text._ZN3povL10focal_blurEPNS_10Ray_StructEPfdd .text._ZN3povL10create_rayEPNS_10Ray_StructEddi .text._ZN3pov5TraceEPNS_10Ray_StructEPfd .text._ZN3povL13IsObjectInCSGEPNS_13Object_StructES1_ .text._ZN3pov30initialize_ray_container_stateEPNS_10Ray_StructEi .text._ZN3povL35initialize_ray_container_state_treeEPNS_10Ray_StructEPNS_16BBox_Tree_StructE .text._ZN3pov31Start_Tracing_Radiosity_PreviewEii .text._ZN3pov26Start_Non_Adaptive_TracingEv .text._ZN3povL11supersampleEPfii .text._ZN3pov22Start_Adaptive_TracingEv .text._ZN3povL15trace_sub_pixelEiPPNS_12Pixel_StructEiiiiiiiPfi .text._ZN3povL21trace_ray_with_offsetEiiddPf .text._ZN3pov18Read_Rendered_PartEPc .text._ZN3pov10Open_ImageEiPciiii .text._ZN3pov23init_output_file_handleEv .text._ZN3pov22setup_output_file_nameEv .text._ZN3pov16open_output_fileEv .text._ZN3pov14sum_statisticsEPxS0_ .text._ZN3pov20Initialize_TokenizerEv .text._ZN3pov13IncludeHeaderEPc .text._ZN3pov18Calculate_Smooth_TEPdS0_S0_S0_ .text._ZN3pov16Prune_Vista_TreeEi .text._ZN3pov17Trace_Primary_RayEPNS_10Ray_StructEPfdi .text._ZN3pov18Build_Vista_BufferEv .text._ZN3povL21project_bounding_slabEPNS_14Project_StructEPPNS_24Project_Tree_Node_StructEPNS_16BBox_Tree_StructE .text._ZN3povL12project_bboxEPNS_14Project_StructEPA3_dPi .text._ZN3povL21project_raw_rectangleEPNS_14Project_StructEPdS2_S2_S2_Pi .text._ZN3pov24Initialize_VLBuffer_CodeEv .text._ZN3pov12Clip_PolygonEPA3_dPiPKdS4_S4_S4_dddd .text._ZN8pov_base7IStream7getlineEPcm)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions11ParseStringEPKcP9POVMSDatab .text._ZN8pov_base14ProcessOptions15Parse_CL_SwitchERPKciP9POVMSDatab .text._ZN8pov_base14ProcessOptions15Parse_CL_OptionERPKcP9POVMSDatab .text._ZN8pov_base14ProcessOptions15Parse_CL_StringERPKci)
. = ALIGN(0x1000);
*(.text._Z11povray_initv)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend16PrintHelpScreensEv)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend10PrintUsageEi)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend14RenderFrontend11StartRenderER12POVMS_Object)
. = ALIGN(0x1000);
*(.text._ZN3pov21Create_Priority_QueueEj)
. = ALIGN(0x1000);
*(.text._ZN3pov15is_image_opaqueEPNS_12Image_StructE .text._ZN3pov12Test_OpacityEPNS_14Texture_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16gatherPhotonsRecEii)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions17Output_INI_OptionEPNS0_16INI_Parser_TableEP9POVMSDataPNS_11OTextStreamE)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput5FlushEi)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend12BannerPrintfEPKcz)
. = ALIGN(0x1000);
*(.text._Z17POVMSObject_MergeP9POVMSDataS0_)
. = ALIGN(0x1000);
*(.text._ZN3pov14extract_colorsEPfPhS1_S1_S1_Pd .text._ZN3pov19prepare_output_lineEPA5_f .text._ZN3pov46output_single_image_line_with_alpha_correctionEPA5_fi)
. = ALIGN(0x1000);
*(.text._ZN3pov24POV_Std_Display_Plot_BoxEiiiijjjj .text._ZN3povL10draw_vistaEPNS_24Project_Tree_Node_StructEPiS2_)
. = ALIGN(0x1000);
*(.text._Z23POVMSAttrList_RemoveNthP9POVMSDatai)
. = ALIGN(0x1000);
*(.text._Z23POVMSStream_WriteStringPKcPhPi)
. = ALIGN(0x1000);
*(.text._Z29POVMSMsg_GetMessageIdentifierP9POVMSDataPj)
. = ALIGN(0x1000);
*(.text._ZN3pov15Default_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov14ot_write_blockEPNS_15ot_block_structEPv)
. = ALIGN(0x1000);
*(.text._ZN3povL23All_Plane_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Inside_PlaneEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Plane_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Copy_PlaneEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Translate_PlaneEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Rotate_PlaneEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16SetCommandOptionEP9POVMSDatajPNS_9shelldataE .text._ZN3pov21Receive_RenderOptionsEP9POVMSDataS1_iPv)
. = ALIGN(0x1000);
*(.text._ZN3pov18BuildRenderOptionsEP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN3pov17Receive_RenderAllEP9POVMSDataS1_iPv)
. = ALIGN(0x1000);
*(.text._ZN3pov18Receive_RenderAreaEP9POVMSDataS1_iPv)
. = ALIGN(0x1000);
*(.text._ZN3pov18Receive_RenderStopEP9POVMSDataS1_iPv)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_ImageD0Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_ImageD2Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_Image10Write_LineEPA5_f)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_Image9Read_LineEPA5_f)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_Image4LineEv)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_Image5WidthEv)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_Image6HeightEv)
. = ALIGN(0x1000);
*(.text._ZN3pov9PPM_ImageC2EPciiii)
. = ALIGN(0x1000);
*(.text._ZN3povL23All_Prism_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Inside_PrismEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL8in_curveEPNS_12Prism_StructEdd)
. = ALIGN(0x1000);
*(.text._ZN3povL12Prism_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Copy_PrismEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Translate_PrismEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL24Transform_SuperellipsoidEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Invert_SuperellipsoidEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Destroy_SuperellipsoidEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9compdistsEPKvS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_ImageD2Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_ImageD0Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_Image10Write_LineEPA5_f .text._ZN3pov11Targa_Image11Write_PixelEdddd)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_Image9Read_LineEPA5_f)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_Image4LineEv)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_Image5WidthEv)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_Image6HeightEv)
. = ALIGN(0x1000);
*(.text._ZN3pov11Targa_ImageC2EPciiii)
. = ALIGN(0x1000);
*(.text._ZN3pov14Copy_TransformEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov17Destroy_TransformEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11compdoublesEPKvS1_)
. = ALIGN(0x1000);
*(.text._ZN3povL22All_Mesh_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Inside_MeshEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov17Check_And_EnqueueEPNS_21Priority_Queue_StructEPNS_16BBox_Tree_StructEPNS_19Bounding_Box_StructEPNS_14Rayinfo_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23intersect_mesh_triangleEPNS_10Ray_StructEPNS_11Mesh_StructEPNS_20Mesh_Triangle_StructEPd)
. = ALIGN(0x1000);
*(.text._ZN3povL11Mesh_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Mesh_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Copy_MeshEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Translate_MeshEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Rotate_MeshEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Scale_MeshEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Transform_MeshEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Invert_MeshEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Destroy_MeshEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9compboxesEPKvS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov8MInvers3EPA3_dS1_ .text._ZN3povL31All_Bicubic_Patch_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3povL17bezier_subdividerEPNS_10Ray_StructEPNS_20Bicubic_Patch_StructEPA4_A4_A3_dddddiPNS_13istack_structE .text._ZN3povL18bezier_tree_walkerEPNS_10Ray_StructEPNS_20Bicubic_Patch_StructEPNS_18Bezier_Node_StructEPNS_13istack_structE .text._ZN3povL18intersect_subpatchEPNS_20Bicubic_Patch_StructEPNS_10Ray_StructEPA3_dPdS6_S6_S6_S6_S6_S6_ .text._ZN3povL12bezier_valueEPA4_A4_A3_dddPdS4_ .text._ZN3povL25bezier_subpatch_intersectEPNS_10Ray_StructEPNS_20Bicubic_Patch_StructEPA4_A4_A3_dddddPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Inside_Bicubic_PatchEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Bicubic_Patch_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Bicubic_Patch_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Invert_BoxEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov11Destroy_BoxEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Copy_Bicubic_PatchEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23Translate_Bicubic_PatchEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Rotate_Bicubic_PatchEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Scale_Bicubic_PatchEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23Transform_Bicubic_PatchEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Invert_Bicubic_PatchEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Destroy_Bicubic_PatchEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22All_Blob_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3povL17intersect_elementEPdS0_PNS_19Blob_Element_StructEdS0_S0_ .text._ZN3povL10insert_hitEPNS_19Blob_Element_StructEddPNS_20Blob_Interval_StructEPj)
. = ALIGN(0x1000);
*(.text._ZN3povL11Inside_BlobEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23calculate_element_fieldEPNS_19Blob_Element_StructEPd)
. = ALIGN(0x1000);
*(.text._ZN3povL11Blob_NormalEPdPNS_13Object_StructEPNS_10istk_entryE .text._ZN3povL14element_normalEPdS0_PNS_19Blob_Element_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Copy_BlobEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Translate_BlobEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Rotate_BlobEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Scale_BlobEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Transform_BlobEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Invert_BlobEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Destroy_BlobEPNS_13Object_StructE .text._ZN3pov33Destroy_Bounding_Sphere_HierarchyEPNS_19BSphere_Tree_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22All_Disc_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Inside_DiscEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Disc_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Copy_DiscEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Translate_DiscEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Rotate_DiscEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Scale_DiscEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Transform_DiscEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Invert_DiscEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Destroy_DiscEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21All_Box_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Inside_BoxEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Box_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Box_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov8Copy_BoxEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Translate_BoxEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Rotate_BoxEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Scale_BoxEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Transform_BoxEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13comp_elementsEPKvS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov18f_hyperbolic_torusEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov18f_isect_ellipsoidsEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov20f_kampyle_of_eudoxusEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov23f_kampyle_of_eudoxus_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_klein_bottleEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov19f_kummer_surface_v1EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov19f_kummer_surface_v2EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov22f_lemniscate_of_geronoEPdj)
. = ALIGN(0x1000);
*(.text._ZN3povL22All_Cone_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Inside_ConeEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Cone_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Copy_ConeEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Translate_ConeEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Rotate_ConeEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Scale_ConeEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Transform_ConeEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Invert_ConeEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Destroy_ConeEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL27All_CSG_Union_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Inside_CSG_UnionEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL8Copy_CSGEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Translate_CSGEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Rotate_CSGEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Scale_CSGEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Transform_CSGEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Invert_CSG_UnionEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Destroy_CSGEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL31All_CSG_Intersect_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL23Inside_CSG_IntersectionEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23Invert_CSG_IntersectionEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL27All_CSG_Merge_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3pov11open_istackEv)
. = ALIGN(0x1000);
*(.text._ZN3povL28All_Parametric_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Inside_ParametricEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Parametric_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Parametric_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov15Copy_ParametricEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Translate_ParametricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Rotate_ParametricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Scale_ParametricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Transform_ParametricEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Invert_ParametricEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov18Destroy_ParametricEPNS_13Object_StructE .text._ZN3pov21Destroy_PrecompParValEPNS_23PrecompParValues_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL25All_Fractal_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Inside_FractalEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov14F_Bound_HComplEPNS_10Ray_StructEPNS_14Fractal_StructEPdS4_)
. = ALIGN(0x1000);
*(.text._ZN3pov19Iteration_HCompl_z3EPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov21D_Iteration_HCompl_z3EPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov21Normal_Calc_HCompl_z3EPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov17F_Bound_HCompl_z3EPNS_10Ray_StructEPNS_14Fractal_StructEPdS4_)
. = ALIGN(0x1000);
*(.text._ZN3pov27Iteration_HCompl_ReciprocalEPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov29D_Iteration_HCompl_ReciprocalEPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov29Normal_Calc_HCompl_ReciprocalEPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov25F_Bound_HCompl_ReciprocalEPNS_10Ray_StructEPNS_14Fractal_StructEPdS4_)
. = ALIGN(0x1000);
*(.text._ZN3pov21Iteration_HCompl_FuncEPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov23D_Iteration_HCompl_FuncEPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov23Normal_Calc_HCompl_FuncEPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov19F_Bound_HCompl_FuncEPNS_10Ray_StructEPNS_14Fractal_StructEPdS4_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Complex_ExpEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Complex_SinEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_SinhEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Complex_CosEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_CoshEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov10Complex_LnEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_ASinEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_ACosEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov13Complex_ASinhEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov13Complex_ACoshEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov13Complex_ATanhEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_ATanEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Complex_TanEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov12f_algbr_cyl1EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov12f_algbr_cyl2EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov12f_algbr_cyl3EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov12f_algbr_cyl4EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_bicornEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_bifoliaEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov6f_blobEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_blob2EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov13f_boy_surfaceEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_commaEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov18f_cross_ellipsoidsEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov16f_crossed_troughEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_cubic_saddleEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_cushionEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_devils_curveEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov17f_devils_curve_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_dupin_cyclidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_ellipsoidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_enneperEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_flange_coverEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov16f_folium_surfaceEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov19f_folium_surface_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov6f_globEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_heartEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov15f_helical_torusEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_helix1EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_helix2EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_hex_xEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_hex_yEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_hetero_mfEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_hunt_surfaceEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov25f_lemniscate_of_gerono_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_mesh1EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_mitreEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov13f_nodal_cubicEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov5f_oddEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov18f_ovals_of_cassiniEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov12f_paraboloidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov17f_parabolic_torusEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov4f_phEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_pillowEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov10f_piriformEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov13f_piriform_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_poly4EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_polytubesEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_quantumEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov20f_quartic_paraboloidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov16f_quartic_saddleEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov18f_quartic_cylinderEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov3f_rEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_ridgeEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_ridged_mfEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov13f_rounded_boxEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_sphereEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_spikesEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_spikes_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_spiralEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov16f_steiners_romanEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_strophoidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov14f_strophoid_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov16f_superellipsoidEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov4f_thEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov7f_torusEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_torus2EPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov15f_torus_gumdropEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov10f_umbrellaEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov17f_witch_of_agnesiEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov20f_witch_of_agnesi_2dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_noise3dEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_patternEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov17f_noise_generatorEPdj)
. = ALIGN(0x1000);
*(.text._ZN3pov9f_pigmentEPdjj)
. = ALIGN(0x1000);
*(.text._ZN3pov5NoiseEPdPNS_14Pattern_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov15Compute_PigmentEPfPNS_14Pigment_StructEPdPNS_10istk_entryE .text._ZN3pov10TurbulenceEPdPNS_11Turb_StructEPNS_14Pattern_StructE .text._ZN3pov17POVFPU_NewContextEv .text._ZN3pov13Evaluate_TPatEPNS_14Pattern_StructEPdPNS_10istk_entryE .text._ZN3pov13image_patternEPdPNS_14Pattern_StructE .text._ZN3pov11Warp_EPointEPdS0_PNS_14Pattern_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL3mapEPdPNS_14Pattern_StructES0_S0_ .text._ZN3povL16planar_image_mapEPdPNS_12Image_StructES0_S0_)
. = ALIGN(0x1000);
*(.text._ZN3povL15image_colour_atEPNS_12Image_StructEddPfPi .text._ZN3povL16no_interpolationEPNS_12Image_StructEddPfPi)
. = ALIGN(0x1000);
*(.text._ZN3pov11f_transformEPdjj)
. = ALIGN(0x1000);
*(.text._ZN3pov8f_splineEPdjj)
. = ALIGN(0x1000);
*(.text._ZN3pov8math_intEd)
. = ALIGN(0x1000);
*(.text._ZN3pov8math_divEdd)
. = ALIGN(0x1000);
*(.text._ZN3pov9expr_growERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov8expr_retERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov8expr_errERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov9expr_noopERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov8expr_putERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov9expr_callERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov8expr_newERPNS_14ExprNodeStructEii)
. = ALIGN(0x1000);
*(.text._ZN3pov28Compute_Coordinate_TransformEPNS_16Transform_StructEPdS2_dd)
. = ALIGN(0x1000);
*(.text._ZN3pov10pov_callocEmmPKciS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov26Compute_Rotation_TransformEPNS_16Transform_StructEPd)
. = ALIGN(0x1000);
*(.text._ZN3povL14sort_and_splitEPPNS_19BSphere_Tree_StructEPS2_Piii)
. = ALIGN(0x1000);
*(.text._ZN3povL9mesh_hashEPPNS_17Hash_Table_StructEPiS3_PPA3_fPd)
. = ALIGN(0x1000);
*(.text._ZN3pov7MInversEPA4_dS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov15Locate_FilenameEPcjb)
. = ALIGN(0x1000);
*(.text._ZN3pov11Copy_CameraEPNS_13Camera_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Parse_CameraEPPNS_13Camera_StructE .text._ZN3pov13Parse_DefaultEv .text._ZN3pov12Parse_ObjectEv .text._ZN3pov10Warn_StateEii .text._ZN3pov17Parse_Object_ModsEPNS_13Object_StructE .text._ZN3povL10Parse_PolyEi .text._ZN3povL18Parse_Mesh_TextureEPPNS_14Texture_StructES2_ .text._ZN3povL9Parse_CSGEi .text._ZN3pov21Parse_Transform_BlockEPNS_16Transform_StructE .text._ZN3pov12Parse_MatrixEPA4_d .text._ZN3povL21Set_CSG_Children_FlagEPNS_13Object_StructEjjj .text._ZN3povL23Parse_Blob_Element_ModsEPNS_19Blob_Element_StructE .text._ZN3pov13Link_TexturesEPPNS_14Texture_StructES1_ .text._ZN3povL26Convert_Filter_To_TransmitEPNS_14Pigment_StructE .text._ZN3pov12Parse_CoeffsEiPd .text._ZN3pov16Parse_Bound_ClipEv .text._ZN3povL17Set_CSG_Tree_FlagEPNS_13Object_StructEji .text._ZN3povL17Parse_Camera_ModsEPNS_13Camera_StructE .text._ZN3pov11Parse_BeginEv .text._ZN3pov9Parse_EndEv .text._ZN3pov13Parse_DeclareEbb .text._ZN3pov12Parse_RValueEiPiPPvPNS_15Sym_Table_EntryEbbbbi .text._ZN3pov15Copy_IdentifierEPvi .text._ZN3pov14Parse_C_StringEb .text._ZN3pov12Parse_StringEb .text._ZN3pov14String_To_UCS2EPcb .text._ZN3pov9Parse_StrEb .text._ZN3pov10Parse_VStrEb .text._ZN3pov12Parse_ConcatEb .text._ZN3pov12Parse_SubstrEb .text._ZN3pov12Parse_StruprEb .text._ZN3pov12Parse_StrlwrEb .text._ZN3pov11Parse_ImageEi .text._ZN3povL13Parse_PatternEPNS_14Pattern_StructEi .text._ZN3povL15Parse_Image_MapEPNS_14Pigment_StructE .text._ZN3pov19Send_ProgressUpdateEii .text._ZN3pov14Read_PPM_ImageEPNS_12Image_StructEPc .text._ZN3pov12Create_PrismEv .text._ZN3pov16Read_Targa_ImageEPNS_12Image_StructEPc .text._ZN3pov7MTimesCEPA4_dS1_S1_ .text._ZN3pov21Compute_Mesh_TriangleEPNS_20Mesh_Triangle_StructEiPdS2_S2_S2_ .text._ZN3pov20Build_Mesh_BBox_TreeEPNS_11Mesh_StructE .text._ZN3pov12Mesh_Hash_UVEPiS0_PPA2_dPd .text._ZN3pov23Create_Mesh_Hash_TablesEv .text._ZN3pov24Destroy_Mesh_Hash_TablesEv .text._ZN3pov12Post_TnormalEPNS_14Tnormal_StructE .text._ZN3pov16Create_SkysphereEv .text._ZN3pov14Copy_SkysphereEPNS_16Skysphere_StructE .text._ZN3pov16Rotate_SkysphereEPNS_16Skysphere_StructEPd .text._ZN3pov19Transform_SkysphereEPNS_16Skysphere_StructEPNS_16Transform_StructE .text._ZN3pov15Scale_SkysphereEPNS_16Skysphere_StructEPd .text._ZN3pov19Translate_SkysphereEPNS_16Skysphere_StructEPd .text._ZN3povL14sort_and_splitEPPNS_16BBox_Tree_StructERS2_Plll .text._ZN3pov11Create_BCylEiPdS0_S0_S0_ .text._ZN3pov22Translate_Blob_ElementEPNS_19Blob_Element_StructEPd .text._ZN3pov22Transform_Blob_ElementEPNS_19Blob_Element_StructEPNS_16Transform_StructE .text._ZN3pov18Scale_Blob_ElementEPNS_19Blob_Element_StructEPd .text._ZN3pov32Create_Blob_Element_Texture_ListEPNS_11Blob_StructEPNS_16Blob_List_StructEi .text._ZN3pov11Create_BlobEv .text._ZN3pov9Make_BlobEPNS_11Blob_StructEdPNS_16Blob_List_StructEi .text._ZN3povL27get_element_bounding_sphereEPNS_19Blob_Element_StructEPdS2_ .text._ZN3pov17Parse_Float_ParamEv .text._ZN3povL13Parse_ExpressEPdPi .text._ZN3povL14Parse_Rel_TermEPdPi .text._ZN3pov18Parse_Scale_VectorEPd .text._ZN3pov12Parse_ColourEPf .text._ZN3pov15Parse_Blend_MapEii .text._ZN3pov16Parse_Blend_ListEiPNS_16Blend_Map_StructEi .text._ZN3pov26Parse_Item_Into_Blend_ListEi .text._ZN3pov16Parse_Colour_MapEv .text._ZN3pov12Parse_SplineEv .text._ZN3pov18Parse_Signed_FloatEv .text._ZN3pov11Create_ConeEv .text._ZN3pov15Create_CylinderEv .text._ZN3pov17Compute_Cone_DataEPNS_13Object_StructE .text._ZN3pov16Compute_CSG_BBoxEPNS_13Object_StructE .text._ZN3pov11Create_DiscEv .text._ZN3pov17Create_ParametricEv .text._ZN3pov28Precompute_Parametric_ValuesEPNS_17Parametric_StructEci .text._ZN3povL15Precomp_Par_IntEidddd .text._ZN3povL16Parse_Rel_FactorEPdPi .text._ZN3povL14Parse_Num_TermEPdPi .text._ZN3povL16Parse_Num_FactorEPdPi .text._ZN3povL11Parse_TraceEPd .text._ZN3pov18Parse_Float_Param2EPdS0_ .text._ZN3pov11Allow_FloatEd .text._ZN3pov12Allow_VectorEPd .text._ZN3pov6FNCode9ParameterEv .text._ZN3pov6FNCode7CompileEPNS_14ExprNodeStructE .text._ZN3pov6FNCode18compile_parametersEv .text._ZN3pov6FNCode17compile_recursiveEPNS_14ExprNodeStructE .text._ZN3pov6FNCode19compile_push_resultEv .text._ZN3pov6FNCode16compile_variableEPc .text._ZN3pov6FNCode14compile_memberEPc .text._ZN3pov6FNCode12compile_callEPNS_14ExprNodeStructEjiPc .text._ZN3pov6FNCode18compile_pop_resultEj .text._ZN3pov6FNCode14compile_selectEPNS_14ExprNodeStructE .text._ZN3pov6FNCode27compile_float_function_callEPNS_14ExprNodeStructEjPc .text._ZN3pov6FNCode28compile_vector_function_callEPNS_14ExprNodeStructEjPc .text._ZN3pov6FNCode14compile_seq_opEPNS_14ExprNodeStructEjd .text._ZN3pov18POVFPU_AddConstantEd .text._ZN3pov18POVFPU_AddFunctionEPNS_12FunctionCodeE .text._ZN3pov10parse_exprEv .text._ZN3pov14expr_get_tokenEv .text._ZN3povL14Parse_Bump_MapEPNS_14Tnormal_StructE .text._ZN3povL19Parse_Image_PatternEPNS_14Pattern_StructE .text._ZN3povL10Parse_WarpEPPNS_12Warps_StructE .text._ZN3povL19Check_BH_ParametersEPNS_15Black_Hole_WarpE .text._ZN3pov13Parse_TnormalEPPNS_14Tnormal_StructE .text._ZN3pov12Parse_FinishEPPNS_13Finish_StructE .text._ZN3pov13Parse_TextureEv .text._ZN3povL11Parse_TilesEv .text._ZN3povL18Parse_Material_MapEv .text._ZN3povL23Parse_Texture_TransformEPNS_14Texture_StructE .text._ZN3pov11Parse_MediaEPPNS_12Media_StructE .text._ZN3pov27Parse_Media_Density_PatternEPPNS_14Pigment_StructE .text._ZN3pov14Parse_InteriorEPPNS_15Interior_StructE .text._ZN3pov9Parse_FogEv .text._ZN3pov13Parse_RainbowEv .text._ZN3pov15Parse_SkysphereEv .text._ZN3pov14Parse_MaterialEPNS_15Material_StructE .text._ZN3pov21Parse_PatternFunctionEPNS_14Pattern_StructE .text._ZN3pov18Translate_TpatternEPNS_14Pattern_StructEPd .text._ZN3pov15Rotate_TpatternEPNS_14Pattern_StructEPd .text._ZN3pov14Scale_TpatternEPNS_14Pattern_StructEPd .text._ZN3pov19Create_Density_FileEv .text._ZN3pov17Read_Density_FileEPNS_19Density_file_StructE .text._ZN3pov14Read_PGM_ImageEPNS_12Image_StructEPc .text._ZN3pov12Post_PigmentEPNS_14Pigment_StructE .text._ZN3pov13SetUp_FractalEPNS_14Fractal_StructE .text._ZN3pov24Allocate_Iteration_StackEi .text._ZN3pov14Parse_FunctionEv .text._ZN3pov21Parse_FunctionContentEv .text._ZN3pov21Parse_DeclareFunctionEPiPKcb .text._ZN3pov19Create_Light_SourceEv .text._ZN3pov17Create_Light_GridEii .text._ZN3pov11Create_PolyEi .text._ZN3pov14Create_PolygonEv .text._ZN3pov15Compute_PolygonEPNS_14Polygon_StructEiPA3_d .text._ZN3pov14Compute_HFieldEPNS_13HField_StructEPNS_12Image_StructE .text._ZN3povL17add_single_normalEPPtiiiiiiiiPd .text._ZN3pov13Create_HFieldEv .text._ZN3pov14Read_Iff_ImageEPNS_12Image_StructEPc .text._ZN3povL9read_longEPN8pov_base7IStreamE .text._ZN3pov15image_height_atEPNS_12Image_StructEii .text._ZN3pov13Copy_MaterialEPNS_15Material_StructE .text._ZN3pov17Create_IsoSurfaceEv .text._ZN3pov12Create_LatheEv .text._ZN3pov13Compute_LatheEPNS_12Lathe_StructEPA2_d .text._ZN3pov13Compute_PrismEPNS_12Prism_StructEPA2_d .text._ZN3pov20Compute_Quadric_BBoxEPNS_14Quadric_StructEPdS2_ .text._ZN3pov10Create_SorEv .text._ZN3pov11Compute_SorEPNS_10Sor_StructEPA2_d .text._ZN3pov13Create_SplineEi .text._ZN3pov19Insert_Spline_EntryEPNS_13Spline_StructEdPd .text._ZN3pov21Create_SuperellipsoidEv .text._ZN3pov13Post_TexturesEPNS_14Texture_StructE .text._ZN3pov9Get_TokenEv .text._ZN3pov15Parse_DirectiveEi .text._ZN3povL16Parse_C_CommentsEv .text._ZN3pov20Parse_String_LiteralEv .text._ZN3povL12Invoke_MacroEv .text._ZN3povL17Return_From_MacroEv .text._ZN3pov17Parse_Ifdef_ParamEv .text._ZN3pov12Open_IncludeEv .text._ZN3povL13Remove_SymbolEiPcbPPvi .text._ZN3povL16Parse_Read_ValueEPNS_16Data_File_StructEiPiPPv .text._ZN3pov10Add_SymbolEiPKci .text._ZN3pov19Parse_Array_DeclareEv .text._ZN3povL16Parse_InitalizerEiiPNS_16Pov_Array_StructE .text._ZN3pov12Create_TorusEv .text._ZN3pov13ProcessNewTTFEPNS_13Object_StructEPcPtdPd .text._ZN3povL19ExtractGlyphOutlineEPNS_18FontFileInfoStructEPjj)
. = ALIGN(0x1000);
*(.text._ZN3pov13optimise_exprEPNS_14ExprNodeStructE .text._ZN3pov25FNSyntax_DeleteExpressionEPNS_14ExprNodeStructE .text._ZN3pov13optimise_callEPNS_14ExprNodeStructE)
. = ALIGN(0x1000);
*(.text._ZN3pov31right_subtree_has_variable_exprEPNS_14ExprNodeStructE)
. = ALIGN(0x1000);
*(.text._ZN3pov22Read_ASCII_File_NumberEPN8pov_base7IStreamE)
. = ALIGN(0x1000);
*(.text._ZN3pov26Compute_Bicubic_Patch_BBoxEPNS_20Bicubic_Patch_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22bezier_bounding_sphereEPA4_A4_A3_dPdS4_ .text._ZN3povL11flat_enoughEPNS_20Bicubic_Patch_StructEPA4_A4_A3_d)
. = ALIGN(0x1000);
*(.text._ZN3pov23Precompute_Patch_ValuesEPNS_20Bicubic_Patch_StructE .text._ZN3povL19bezier_tree_builderEPNS_20Bicubic_Patch_StructEPA4_A4_A3_dddddiRi)
. = ALIGN(0x1000);
*(.text._ZN3povL19bezier_tree_deleterEPNS_18Bezier_Node_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov6FNCodeC2EPNS_12FunctionCodeEbPKc)
. = ALIGN(0x1000);
*(.text._ZN3pov30Promote_Local_Lights_RecursiveEPNS_22Compound_Object_StructEPNS_19Light_Source_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov13Rotate_ObjectEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov12Scale_ObjectEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov29Evaluate_Function_Interval_UVEjdPdS0_dRdS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov6DNoiseEPdS0_)
. = ALIGN(0x1000);
*(.text._ZN3pov23Precompute_Cubic_CoeffsEPNS_13Spline_StructE .text._ZN3pov14Get_Spline_ValEPNS_13Spline_StructEdPdPi)
. = ALIGN(0x1000);
*(.text._ZN3pov19Found_Instead_ErrorEPKcS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov10pov_strdupEPKc)
. = ALIGN(0x1000);
*(.text._ZN3povL14Fractal_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Copy_FractalEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Translate_FractalEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Rotate_FractalEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Scale_FractalEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Transform_FractalEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Invert_FractalEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Destroy_FractalEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16Iteration_HComplEPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov18D_Iteration_HComplEPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov18Normal_Calc_HComplEPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Scale_PlaneEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Transform_PlaneEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Invert_PlaneEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Destroy_PlaneEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL30All_Light_Source_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3pov12IntersectionEPNS_10istk_entryEPNS_13Object_StructEPNS_10Ray_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Inside_Light_SourceEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Light_Source_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Light_Source_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Copy_Light_SourceEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov11Copy_ObjectEPNS_13Object_StructE .text._ZN3pov10Copy_MediaEPNS_12Media_StructE .text._ZN3pov12Copy_TnormalEPNS_14Tnormal_StructE .text._ZN3pov16Copy_TPat_FieldsEPNS_14Pattern_StructES1_ .text._ZN3pov12Copy_PigmentEPNS_14Pigment_StructE .text._ZN3pov13Copy_TexturesEPNS_14Texture_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov11Create_WarpEi .text._ZN3pov10Copy_WarpsEPNS_12Warps_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Translate_Light_SourceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16Translate_ObjectEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Rotate_Light_SourceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Scale_Light_SourceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Transform_Light_SourceEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov18Transform_TpatternEPNS_14Pattern_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16Transform_ObjectEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Invert_Light_SourceEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Destroy_Light_SourceEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22All_Poly_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3povL8binomialEii)
. = ALIGN(0x1000);
*(.text._ZN3povL11Inside_PolyEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Poly_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Copy_PolyEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Translate_PolyEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Rotate_PolyEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Scale_PolyEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Transform_PolyEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Invert_PolyEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Destroy_PolyEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL25All_Polygon_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Inside_PolygonEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Polygon_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Copy_PolygonEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Translate_PolygonEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Rotate_PolygonEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Scale_PolygonEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Transform_PolygonEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Compute_Polygon_BBoxEPNS_14Polygon_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Invert_PolygonEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Destroy_PolygonEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov12Complex_TanhEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Complex_PwrEPNS_5cmplxES1_)
. = ALIGN(0x1000);
*(.text._ZN3povL24All_HField_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3povL15intersect_pixelEiiPNS_10Ray_StructEPNS_13HField_StructEddRPNS_13istack_structERS1_RdS8_ .text._ZN3povL13dda_traversalEPNS_10Ray_StructEPNS_13HField_StructEPdPNS_19HField_Block_StructERPNS_13istack_structERS1_RdSB_)
. = ALIGN(0x1000);
*(.text._ZN3povL13Inside_HFieldEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13HField_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Copy_HFieldEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Translate_HFieldEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Rotate_HFieldEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Scale_HFieldEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Transform_HFieldEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Invert_HFieldEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Destroy_HFieldEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL28All_IsoSurface_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3pov29IsoSurface_Function_Find_RootEPNS_17IsoSurface_StructEPdS2_S2_S2_b .text._ZN3pov31IsoSurface_Function_Find_Root_REPNS_17IsoSurface_StructEPNS_8ISO_PairES3_dddb)
. = ALIGN(0x1000);
*(.text._ZN3pov13Intersect_BoxEPNS_10Ray_StructEPNS_16Transform_StructEPdS4_S4_S4_PiS5_)
. = ALIGN(0x1000);
*(.text._ZN3povL17Inside_IsoSurfaceEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17IsoSurface_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov17POVFPU_RunDefaultEj)
. = ALIGN(0x1000);
*(.text._Z23povray_getoutputcontextv .text._ZN3pov7ErrorAtEPKclmS1_z .text._Z21POVMSMsg_SetupMessageP9POVMSDatajj .text._Z15POVMSObject_NewP9POVMSDataj)
. = ALIGN(0x1000);
*(.text._ZN3pov15Copy_IsoSurfaceEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Translate_IsoSurfaceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Rotate_IsoSurfaceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Scale_IsoSurfaceEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Transform_IsoSurfaceEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Invert_IsoSurfaceEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov18Destroy_IsoSurfaceEPNS_13Object_StructE .text._ZN3pov9WarningAtEjPKclmS1_z)
. = ALIGN(0x1000);
*(.text._ZN3pov10Debug_InfoEPKcz)
. = ALIGN(0x1000);
*(.text._ZN3povL23All_Lathe_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Inside_LatheEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Lathe_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Lathe_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Copy_LatheEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Translate_LatheEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Rotate_LatheEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Scale_LatheEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Transform_LatheEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Invert_LatheEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Destroy_LatheEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStreamD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStreamD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11OTextStreamD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11OTextStreamD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStreamC2EPKcPNS_7IStreamE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11OTextStreamC2EPKcPNS_7OStreamE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBufferD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBufferD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer10lineoutputEPKcj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer12directoutputEPKcj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer9rawoutputEPKcj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBufferC2Emj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base19DefaultPlatformBaseD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base19DefaultPlatformBaseD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base19DefaultPlatformBase13CreateIStreamEj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base19DefaultPlatformBase13CreateOStreamEj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base19DefaultPlatformBaseC2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontendD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontendD0Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend12CloseStreamsEv)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend19DefaultStreamBufferD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend19DefaultStreamBufferD0Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend19DefaultStreamBuffer10lineoutputEPKcj)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend19DefaultStreamBuffer12directoutputEPKcj)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontendC2EPvS1_)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend11OpenStreamsEb)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutputC2EPv .text._ZN12pov_frontend14RenderFrontendC2EPvS1_ .text._ZN21POVMS_MessageReceiver12AddNodeFrontEjjPNS_9HandlerOOEPNS_7HandlerE .text._ZN21POVMS_MessageReceiver11AddNodeBackEjjPNS_9HandlerOOEPNS_7HandlerE)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend21DefaultRenderFrontend19DefaultStreamBufferC2EPN8pov_base7OStreamEbb)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutputD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutputD0Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput8InitInfoEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput13RenderOptionsEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput13RenderStartedEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._Z25POVMSUtil_GetStringLengthP9POVMSDatajPi)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput15FrameStatisticsEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput15ParseStatisticsEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput16RenderStatisticsEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput10RenderDoneEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput8ProgressEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_GetBoolP9POVMSDatajPi)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput7WarningEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput5ErrorEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput10FatalErrorEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput11FileMessageEiP9POVMSData)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_GetLongP9POVMSDatajPx)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer9printfileEP8_IO_FILEi)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput9DebugInfoEP9POVMSDataS2_i)
. = ALIGN(0x1000);
*(.text._Z19POVMSUtil_GetStringP9POVMSDatajPcPi)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer6printfEPKcz .text._ZN8pov_base16TextStreamBuffer11directflushEPKcj)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend13MessageOutput6PrintfEiPKcz)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver13MemberHandlerIN12pov_frontend13MessageOutputEE4CallEP9POVMSDataS5_i)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver7HandlerD2Ev)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver13MemberHandlerIN12pov_frontend13MessageOutputEED0Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions24ReadSpecialOptionHandlerEPN8pov_base14ProcessOptions16INI_Parser_TableEPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions24ReadSpecialSwitchHandlerEPN8pov_base14ProcessOptions16Cmd_Parser_TableEPcP9POVMSDatab)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions25WriteSpecialOptionHandlerEPN8pov_base14ProcessOptions16INI_Parser_TableEP9POVMSDataPNS1_11OTextStreamE)
. = ALIGN(0x1000);
*(.text._Z18POVMSUtil_GetFloatP9POVMSDatajPf)
. = ALIGN(0x1000);
*(.text._ZN8pov_base7OStream6printfEPKcz)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11OTextStream6printfEPKcz)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions17WriteOptionFilterEPN8pov_base14ProcessOptions16INI_Parser_TableE)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions20ProcessUnknownStringEPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions6IsTrueEPKc .text._ZN8pov_base14ProcessOptions14Process_SwitchEPNS0_16Cmd_Parser_TableEPcP9POVMSDatab .text._ZN8pov_base14ProcessOptions18Process_INI_OptionEPNS0_16INI_Parser_TableEPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStream5seekgENS0_7FilePosE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStream7getcharEv)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions9ParseFileEPKcP9POVMSData .text._ZN8pov_base14ProcessOptions23Parse_INI_SpecificationEPKcRPcS4_ .text._ZN8pov_base14ProcessOptions20Parse_INI_Skip_SpaceEPNS_11ITextStreamEb .text._ZN8pov_base14ProcessOptions16Parse_INI_SwitchEPNS_11ITextStreamEiP9POVMSData .text._ZN8pov_base14ProcessOptions16Parse_INI_OptionEPNS_11ITextStreamEP9POVMSData .text._ZN8pov_base14ProcessOptions16Parse_INI_StringEPNS_11ITextStreamEib .text._ZN8pov_base14ProcessOptions26Parse_INI_String_SmartmodeEPNS_11ITextStreamE)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions15OpenFileForReadEPKcP9POVMSData .text._ZN12pov_frontend20ProcessRenderOptions17OpenINIFileStreamEPKcjPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._Z15POVMSObject_GetP9POVMSDataS0_j)
. = ALIGN(0x1000);
*(.text._Z20POVMSAttrList_GetNthP9POVMSDataiS0_)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11ITextStreamC2EPKcj)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptions16OpenFileForWriteEPKcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base11OTextStreamC2EPKcjb)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptionsC2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend20ProcessRenderOptionsD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend14RenderFrontendD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend14RenderFrontendD0Ev)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend14RenderFrontend13RenderStartedER13POVMS_MessageS2_i)
. = ALIGN(0x1000);
*(.text._ZN12pov_frontend14RenderFrontend10RenderDoneER13POVMS_MessageS2_i)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver15MemberHandlerOOIN12pov_frontend14RenderFrontendEE4CallER13POVMS_MessageS5_i)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver9HandlerOOD2Ev)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiver15MemberHandlerOOIN12pov_frontend14RenderFrontendEED0Ev)
. = ALIGN(0x1000);
*(.text._ZN3povL12Rotate_PrismEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Scale_PrismEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Transform_PrismEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Invert_PrismEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Destroy_PrismEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL25All_Quadric_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Inside_QuadricEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Quadric_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Copy_QuadricEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Translate_QuadricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Rotate_QuadricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Scale_QuadricEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL17Transform_QuadricEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Invert_QuadricEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Destroy_QuadricEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov12Iteration_z3EPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov15Iteration_JuliaEPdPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov14D_Iteration_z3EPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov17D_Iteration_JuliaEPdPNS_14Fractal_StructES0_)
. = ALIGN(0x1000);
*(.text._ZN3pov14Normal_Calc_z3EPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov17Normal_Calc_JuliaEPdiPNS_14Fractal_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov13F_Bound_JuliaEPNS_10Ray_StructEPNS_14Fractal_StructEPdS4_)
. = ALIGN(0x1000);
*(.text._ZN3povL15ra_average_nearEPNS_15ot_block_structEPv)
. = ALIGN(0x1000);
*(.text._ZN3povL21All_Sor_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3pov14Intersect_BCylEPNS_11BCyl_StructEPdS2_)
. = ALIGN(0x1000);
*(.text._ZN3povL10Inside_SorEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Sor_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Sor_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL8Copy_SorEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Translate_SorEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Rotate_SorEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Scale_SorEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Transform_SorEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Invert_SorEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Destroy_SorEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov12Destroy_BCylEPNS_11BCyl_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL24All_Sphere_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Inside_SphereEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Sphere_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Sphere_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov11Copy_SphereEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Translate_SphereEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Rotate_SphereEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Scale_SphereEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16Transform_SphereEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Invert_SphereEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov14Destroy_SphereEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL27All_Ellipsoid_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Inside_EllipsoidEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Ellipsoid_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3pov17Copy_Sphere_SweepEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov29Intersect_Sphere_Sweep_SphereEPNS_10Ray_StructEPNS_26Sphere_Sweep_Sphere_StructEPNS_35Sphere_Sweep_Intersection_StructureE .text._ZN3pov30Intersect_Sphere_Sweep_SegmentEPNS_10Ray_StructEPNS_27Sphere_Sweep_Segment_StructEPNS_35Sphere_Sweep_Intersection_StructureE .text._ZN3povL30All_Sphere_Sweep_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Inside_Sphere_SweepEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Sphere_Sweep_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Translate_Sphere_SweepEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Rotate_Sphere_SweepEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Scale_Sphere_SweepEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov20Compute_Sphere_SweepEPNS_19Sphere_Sweep_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov22Transform_Sphere_SweepEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Invert_Sphere_SweepEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov20Destroy_Sphere_SweepEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Comp_IsectsEPKvS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov11Copy_SplineEPNS_13Spline_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL32All_Superellipsoid_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text.spec_qsort)
. = ALIGN(0x1000);
*(.text._ZN3povL21Inside_SuperellipsoidEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23evaluate_superellipsoidEPdPNS_21Superellipsoid_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Superellipsoid_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL19Copy_SuperellipsoidEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL24Translate_SuperellipsoidEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Rotate_SuperellipsoidEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Scale_SuperellipsoidEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL23All_Torus_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE .text._ZN3pov19Test_Thick_CylinderEPdS0_dddd)
. = ALIGN(0x1000);
*(.text._ZN3pov16Solve_PolynomialEiPdS0_id .text._ZN3povL9polysolveEiPdS0_ .text._ZN3povL11solve_cubicEPdS0_ .text._ZN3povL7sbisectEiPNS_1pEddiiPd)
. = ALIGN(0x1000);
*(.text._ZN3povL12Inside_TorusEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Torus_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Torus_UVCoordEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Copy_TorusEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Translate_TorusEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Rotate_TorusEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Scale_TorusEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Transform_TorusEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Invert_TorusEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Destroy_TorusEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL26All_Triangle_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Inside_TriangleEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Triangle_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Copy_TriangleEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Translate_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Rotate_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL14Scale_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL18Transform_TriangleEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL15Invert_TriangleEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL16Destroy_TriangleEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Smooth_Triangle_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL20Copy_Smooth_TriangleEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL25Translate_Smooth_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Rotate_Smooth_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21Scale_Smooth_TriangleEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov16Compute_TriangleEPNS_15Triangle_StructEi)
. = ALIGN(0x1000);
*(.text._ZN3povL25Transform_Smooth_TriangleEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL22Invert_Smooth_TriangleEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL21All_TTF_IntersectionsEPNS_13Object_StructEPNS_10Ray_StructEPNS_13istack_structE)
. = ALIGN(0x1000);
*(.text._ZN3pov13Inside_ObjectEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Inside_TTFEPdPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL12Inside_GlyphEddPNS_11GlyphStructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10TTF_NormalEPdPNS_13Object_StructEPNS_10istk_entryE)
. = ALIGN(0x1000);
*(.text._ZN3povL8Copy_TTFEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._Z18POVMSUtil_SetFloatP9POVMSDatajf)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_SetBoolP9POVMSDataji)
. = ALIGN(0x1000);
*(.text._ZN8pov_base16TextStreamBuffer9lineflushEv)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_SetLongP9POVMSDatajx)
. = ALIGN(0x1000);
*(.text._ZN3pov7WarningEjPKcz)
. = ALIGN(0x1000);
*(.text._ZN3pov13Where_WarningEP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN3pov13PossibleErrorEPKcz)
. = ALIGN(0x1000);
*(.text._ZN3pov14Destroy_ObjectEPNS_13Object_StructE .text._ZN3pov15Destroy_IStacksEv .text._ZN3pov15ot_free_subtreeEPNS_14ot_node_structE .text._ZN3pov13Destroy_FrameEv .text._ZN3pov18Destroy_Ident_DataEPvi .text._Z16povray_terminatev .text._Z11povray_exiti .text._ZN3pov12Do_CooperateEi .text._ZN3pov11pov_reallocEPvmPKciS2_ .text._ZN3pov17Free_Noise_TablesEv .text._ZN3pov13Destroy_MediaEPNS_12Media_StructE .text._ZN3pov11Destroy_FogEPNS_10Fog_StructE .text._ZN3pov17Destroy_SkysphereEPNS_16Skysphere_StructE .text._ZN3pov22Deinitialize_BBox_CodeEv .text._ZN3pov22Destroy_Priority_QueueEPNS_21Priority_Queue_StructE .text._ZN3pov17Destroy_BBox_TreeEPNS_16BBox_Tree_StructE .text._ZN3pov14Destroy_CameraEPNS_13Camera_StructE .text._ZN3pov17Destroy_Blend_MapEPNS_16Blend_Map_StructE .text._ZN3pov13FNCode_DeleteEPNS_12FunctionCodeE .text._ZN3pov12POVFPU_ResetEv .text._ZN3pov21POVFPU_RemoveFunctionEj .text._ZN3pov19Destroy_TPat_FieldsEPNS_14Pattern_StructE .text._ZN3pov20Destroy_Density_FileEPNS_19Density_file_StructE .text._ZN3pov23FreeBacktraceEverythingEv .text._ZN3pov15Destroy_PigmentEPNS_14Pigment_StructE .text._ZN3pov20Free_Iteration_StackEv .text._ZN3pov13Destroy_ImageEPNS_12Image_StructE .text._ZN3pov16Destroy_MaterialEPNS_15Material_StructE .text._ZN3pov21Destroy_Light_BuffersEv .text._ZN3pov26Deinitialize_Lighting_CodeEv .text._ZN8pov_base12pov_tsprintfEPKcz .text._ZN3pov27Deinitialize_Radiosity_CodeEv .text._ZN3pov9close_allEv .text._ZN3pov18Terminate_RendererEv .text._ZN3pov14Destroy_SplineEPNS_13Spline_StructE .text._ZN3pov16Destroy_TexturesEPNS_14Texture_StructE .text._ZN3pov19Terminate_TokenizerEv .text._ZN3pov11Where_ErrorEP9POVMSData .text._ZN3pov13Destroy_MacroEPNS_16Pov_Macro_StructE .text._ZN3pov12FreeFontInfoEv .text._ZN3pov5ErrorEPKcz .text._ZN3pov12pov_shelloutENS_9shelltypeE .text._ZN3pov26Deinitialize_VLBuffer_CodeEv .text._ZN3pov20Destroy_Project_TreeEPNS_24Project_Tree_Node_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov11ot_traverseEPNS_14ot_node_structEPFbPNS_15ot_block_structEPvES4_)
. = ALIGN(0x1000);
*(.text._ZN3pov13BuildProgressEP9POVMSDatai .text._ZN3pov13Send_ProgressEPKci)
. = ALIGN(0x1000);
*(.text._Z18POVMS_CloseContextPv)
. = ALIGN(0x1000);
*(.text._ZN3povL13Translate_TTFEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL10Rotate_TTFEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL9Scale_TTFEPNS_13Object_StructEPdPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL13Transform_TTFEPNS_13Object_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov14Recompute_BBoxEPNS_19Bounding_Box_StructEPNS_16Transform_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov7MTimesAEPA4_dS1_)
. = ALIGN(0x1000);
*(.text._ZN3pov7MTimesBEPA4_dS1_)
. = ALIGN(0x1000);
*(.text._ZN3povL10Invert_TTFEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3povL11Destroy_TTFEPNS_13Object_StructE)
. = ALIGN(0x1000);
*(.text._ZN3pov21DebugTextStreamBufferD2Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov21DebugTextStreamBufferD0Ev)
. = ALIGN(0x1000);
*(.text._ZN3pov21DebugTextStreamBuffer10lineoutputEPKcj)
. = ALIGN(0x1000);
*(.text._Z21POVMS_ProcessMessagesPvi .text._Z30POVMS_Sys_QueueReceive_DefaultP27POVMS_Sys_QueueNode_DefaultPib .text._Z13POVMS_ReceivePvP9POVMSDataS1_i .text._Z10POVMS_SendPvP9POVMSDataS1_i)
. = ALIGN(0x1000);
*(.text._Z19POVMS_WriteToStdoutPvi)
. = ALIGN(0x1000);
*(.text._Z16POVMSStream_SizeP9POVMSData)
. = ALIGN(0x1000);
*(.text._Z16POVMSStream_ReadP9POVMSDataPhPi)
. = ALIGN(0x1000);
*(.text._Z17POVMSStream_WriteP9POVMSDataPhPi)
. = ALIGN(0x1000);
*(.text._Z25POVMSMsg_GetSourceAddressP9POVMSDataPPv)
. = ALIGN(0x1000);
*(.text._Z30POVMSMsg_GetDestinationAddressP9POVMSDataPPv)
. = ALIGN(0x1000);
*(.text._Z16POVMSUtil_GetIntP9POVMSDatajPi)
. = ALIGN(0x1000);
*(.text._Z16POVMSUtil_SetIntP9POVMSDataji)
. = ALIGN(0x1000);
*(.text._Z19POVMSUtil_SetStringP9POVMSDatajPKc)
. = ALIGN(0x1000);
*(.text._ZN3pov21DebugTextStreamBuffer12directoutputEPKcj)
. = ALIGN(0x1000);
*(.text._GLOBAL__sub_I_userio.cpp)
. = ALIGN(0x1000);
*(.text._ZN3pov21DebugTextStreamBufferC2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base6IOBaseD2Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base6IOBaseD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base6IOBase4openEPKcj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base6IOBase5closeEv)
. = ALIGN(0x1000);
*(.text._ZN8pov_base7IStreamD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base7OStreamD0Ev)
. = ALIGN(0x1000);
*(.text._ZN8pov_base6IOBaseC2Ejj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base7IStreamC2Ej)
. = ALIGN(0x1000);
*(.text._ZN8pov_base7OStreamC2Ej)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_ContainerD2Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_ContainerD0Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeD2Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeD0Ev)
. = ALIGN(0x1000);
*(.text._ZN10POVMS_ListD2Ev)
. = ALIGN(0x1000);
*(.text._ZN10POVMS_ListD0Ev)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectD2Ev)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectD0Ev)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiverD0Ev)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiverD2Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_ContainerC2Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Ev)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2EPKc)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Ei)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Ex)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Ef)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Eb)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2Ej)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2ER9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN15POVMS_AttributeC2ERS_)
. = ALIGN(0x1000);
*(.text._ZN10POVMS_ListC2Ev)
. = ALIGN(0x1000);
*(.text._ZN10POVMS_ListC2ER9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN10POVMS_ListC2ERS_)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectC2Ej)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectC2ER9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectC2EP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectC2ERS_)
. = ALIGN(0x1000);
*(.text._Z30POVMSMsg_SetDestinationAddressP9POVMSDataPv)
. = ALIGN(0x1000);
*(.text._Z25POVMSMsg_SetSourceAddressP9POVMSDataPv)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageC2Ejjj)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageD0Ev)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageC2ER9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageC2EP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageC2ER12POVMS_Object)
. = ALIGN(0x1000);
*(.text._ZN13POVMS_MessageC2ERS_)
. = ALIGN(0x1000);
*(.text._ZN21POVMS_MessageReceiverC2EPv)
. = ALIGN(0x1000);
*(.text._ZN12POVMS_ObjectclEv .text._ZN21POVMS_MessageReceiver14ReceiveHandlerEP9POVMSDataS1_iPv)
. = ALIGN(0x1000);
*(.text._Z18POVMSObject_DeleteP9POVMSData .text._Z16POVMSAttr_DeleteP9POVMSData)
. = ALIGN(0x1000);
*(.text.__clang_call_terminate)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_SetTypeP9POVMSDatajj)
. = ALIGN(0x1000);
*(.text._Z16POVMSObject_CopyP9POVMSDataS0_ .text._Z18POVMSAttrList_CopyP9POVMSDataS0_ .text._Z14POVMSAttr_CopyP9POVMSDataS0_)
. = ALIGN(0x1000);
*(.text._Z24POVMSMsg_GetMessageClassP9POVMSDataPj)
. = ALIGN(0x1000);
*(.text._Z17POVMSUtil_GetTypeP9POVMSDatajPj)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions24ReadSpecialOptionHandlerEPNS0_16INI_Parser_TableEPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions24ReadSpecialSwitchHandlerEPNS0_16Cmd_Parser_TableEPcP9POVMSDatab)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions25WriteSpecialOptionHandlerEPNS0_16INI_Parser_TableEP9POVMSDataPNS_11OTextStreamE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions17WriteOptionFilterEPNS0_16INI_Parser_TableE)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions20ProcessUnknownSwitchEPcS1_P9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions20ProcessUnknownStringEPcP9POVMSData)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions10ParseErrorEPKcz)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions12ParseErrorAtEPNS_11ITextStreamEPKcz)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptions10WriteErrorEPKcz)
. = ALIGN(0x1000);
*(.text._ZN8pov_base14ProcessOptionsD2Ev)
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
