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
*(.text.GetPathComponents)
. = ALIGN(0x1000);
*(.text.CanonicalXMLContent .text.XMLTreeTagToXML .text.EncodePredefinedEntities)
. = ALIGN(0x1000);
*(.text.MagickCoreGenesis)
. = ALIGN(0x1000);
*(.text.MagickCommandGenesis)
. = ALIGN(0x1000);
*(.text.NewDrawingWand)
. = ALIGN(0x1000);
*(.text.EscapeString)
. = ALIGN(0x1000);
*(.text.ImageToBlob)
. = ALIGN(0x1000);
*(.text.Base64Encode)
. = ALIGN(0x1000);
*(.text.MagickToMime)
. = ALIGN(0x1000);
*(.text.XMLTreeInfoToXML)
. = ALIGN(0x1000);
*(.text.MvgAutoWrapPrintf)
. = ALIGN(0x1000);
*(.text.PixelGetQuantumColor)
. = ALIGN(0x1000);
*(.text.MvgPrintf)
. = ALIGN(0x1000);
*(.text.CloneMagickWandFromImages)
. = ALIGN(0x1000);
*(.text.ConvolveImageChannel)
. = ALIGN(0x1000);
*(.text.ConstituteImage)
. = ALIGN(0x1000);
*(.text.RemoveNodeFromSplayTree)
. = ALIGN(0x1000);
*(.text.ReadBlobLongLong)
. = ALIGN(0x1000);
*(.text.WriteBlobLong)
. = ALIGN(0x1000);
*(.text.SimilarityMetricImage)
. = ALIGN(0x1000);
*(.text.Ascii85Encode)
. = ALIGN(0x1000);
*(.text.Ascii85Flush)
. = ALIGN(0x1000);
*(.text.ImportImagePixels)
. = ALIGN(0x1000);
*(.text.ResetSplayTree)
. = ALIGN(0x1000);
*(.text.PlasmaImageProxy)
. = ALIGN(0x1000);
*(.text.StereoAnaglyphImage)
. = ALIGN(0x1000);
*(.text.ExportImagePixels)
. = ALIGN(0x1000);
*(.text.ImagesToBlob)
. = ALIGN(0x1000);
*(.text.GetImageChannelDistortions)
. = ALIGN(0x1000);
*(.text.NewPixelWands)
. = ALIGN(0x1000);
*(.text.NewMagickImage)
. = ALIGN(0x1000);
*(.text.MagickOpaquePaintImageChannel)
. = ALIGN(0x1000);
*(.text.MagickRandomThresholdImageChannel)
. = ALIGN(0x1000);
*(.text.GetMimeInfo)
. = ALIGN(0x1000);
*(.text.SetImageColor)
. = ALIGN(0x1000);
*(.text.SteganoImage)
. = ALIGN(0x1000);
*(.text.GetConfigureList)
. = ALIGN(0x1000);
*(.text.GetMultilineTypeMetrics)
. = ALIGN(0x1000);
*(.text.GetTypeList)
. = ALIGN(0x1000);
*(.text.GetMagickList)
. = ALIGN(0x1000);
*(.text.NewMagickWand)
. = ALIGN(0x1000);
*(.text.StringToInteger)
. = ALIGN(0x1000);
*(.text.DistributePixelCacheServer)
. = ALIGN(0x1000);
*(.text.AcquireTimerInfo)
. = ALIGN(0x1000);
*(.text.MogrifyUsage)
. = ALIGN(0x1000);
*(.text.ClonePixelWand)
. = ALIGN(0x1000);
*(.text.NewPixelWand)
. = ALIGN(0x1000);
*(.text.GetMagickHomeURL)
. = ALIGN(0x1000);
*(.text.GetImageArtifact)
. = ALIGN(0x1000);
*(.text.CloneCacheView)
. = ALIGN(0x1000);
*(.text.ClonePixelWands)
. = ALIGN(0x1000);
*(.text.PixelGetPreviousIteratorRow)
. = ALIGN(0x1000);
*(.text.RemapImages)
. = ALIGN(0x1000);
*(.text.GetImageAttribute)
. = ALIGN(0x1000);
*(.text.GetOneAuthenticPixel)
. = ALIGN(0x1000);
*(.text.ImportQuantumPixels)
. = ALIGN(0x1000);
*(.text.SpliceImageIntoList)
. = ALIGN(0x1000);
*(.text.GetImageDynamicThreshold)
. = ALIGN(0x1000);
*(.text.ReadTGAImage)
. = ALIGN(0x1000);
*(.text.WriteTGAImage)
. = ALIGN(0x1000);
*(.text.SetBlobExtent)
. = ALIGN(0x1000);
*(.text.WriteStreamImage .text.StreamImagePixels)
. = ALIGN(0x1000);
*(.text.WriteBlob)
. = ALIGN(0x1000);
*(.text.TypeInfoCompare)
. = ALIGN(0x1000);
*(.text.TypeCompare)
. = ALIGN(0x1000);
*(.text.FileCompare)
. = ALIGN(0x1000);
*(.text.ConvertImageCommand .text.ConvertUsage .text.PingImages)
. = ALIGN(0x1000);
*(.text.DestroyTypeNode)
. = ALIGN(0x1000);
*(.text.SyncImage)
. = ALIGN(0x1000);
*(.text.ConvertHCLpToRGB .text.ConvertHSIToRGB .text.ConvertLCHuvToRGB .text.ConvertRGBToLCHab)
. = ALIGN(0x1000);
*(.text.TransformImageColorspace .text.TransformRGBImage .text.RGBTransformImage)
. = ALIGN(0x1000);
*(.text.IsGrayImage)
. = ALIGN(0x1000);
*(.text.AcquireImageColormap)
. = ALIGN(0x1000);
*(.text.SetImageOpacity)
. = ALIGN(0x1000);
*(.text.IsColorSimilar)
. = ALIGN(0x1000);
*(.text.IsMonochromeImage)
. = ALIGN(0x1000);
*(.text.IsPaletteImage)
. = ALIGN(0x1000);
*(.text.IsOpaqueImage .text.GetMagickProperty .text.GetMagickPropertyLetter .text.InterpretImageProperties)
. = ALIGN(0x1000);
*(.text.StringInfoToHexString .text.SignatureImage)
. = ALIGN(0x1000);
*(.text.GetImageBoundingBox)
. = ALIGN(0x1000);
*(.text.IsMagickColorSimilar)
. = ALIGN(0x1000);
*(.text.ExportQuantumPixels)
. = ALIGN(0x1000);
*(.text.SetQuantumDepth)
. = ALIGN(0x1000);
*(.text.AcquireQuantumInfo .text.GetQuantumInfo)
. = ALIGN(0x1000);
*(.text.DestroyColorCube)
. = ALIGN(0x1000);
*(.text.ClassifyImageColors)
. = ALIGN(0x1000);
*(.text.SetImageRegistry)
. = ALIGN(0x1000);
*(.text.SetMagickResourceLimit)
. = ALIGN(0x1000);
*(.text.StatisticImageChannel .text.GetMinimumPixelList .text.GetMaximumPixelList)
. = ALIGN(0x1000);
*(.text.GetOptimalKernelWidth2D)
. = ALIGN(0x1000);
*(.text.ColorMatrixImage)
. = ALIGN(0x1000);
*(.text.DestroyKernelInfo)
. = ALIGN(0x1000);
*(.text.CloneKernelInfo .text.RotateKernelInfo)
. = ALIGN(0x1000);
*(.text.AcquireKernelInfo .text.AcquireKernelBuiltIn .text.ExpandMirrorKernelInfo .text.ParseKernelArray)
. = ALIGN(0x1000);
*(.text.ScaleKernelInfo)
. = ALIGN(0x1000);
*(.text.RotationalBlurImageChannel)
. = ALIGN(0x1000);
*(.text.GetImageQuantizeError)
. = ALIGN(0x1000);
*(.text.ParseMetaGeometry)
. = ALIGN(0x1000);
*(.text.TransparentPaintImage)
. = ALIGN(0x1000);
*(.text.OpaquePaintImageChannel)
. = ALIGN(0x1000);
*(.text.FloodfillPaintImage)
. = ALIGN(0x1000);
*(.text.RelinquishVirtualMemory)
. = ALIGN(0x1000);
*(.text.AcquireVirtualMemory)
. = ALIGN(0x1000);
*(.text.SetImageBackgroundColor)
. = ALIGN(0x1000);
*(.text.AcquireResampleFilter .text.SetResampleFilter .text.ScaleResampleFilter .text.ResamplePixelColor .text.CompositeImageChannel .text.CompositeMinus .text.CompositeDivide .text.CompositeHardLight .text.SoftLight)
. = ALIGN(0x1000);
*(.text.MergeImageLayers)
. = ALIGN(0x1000);
*(.text.ApplyEvaluateOperator)
. = ALIGN(0x1000);
*(.text.GenerateDifferentialNoise)
. = ALIGN(0x1000);
*(.text.AcquirePixelThreadSet)
. = ALIGN(0x1000);
*(.text.EvaluateImages)
. = ALIGN(0x1000);
*(.text.CloneQuantizeInfo)
. = ALIGN(0x1000);
*(.text.ClassifyImageColors.4293 .text.PruneChild .text.PruneLevel .text.PruneToCubeDepth)
. = ALIGN(0x1000);
*(.text.GetCubeInfo)
. = ALIGN(0x1000);
*(.text.AssignImageColors .text.DefineImageColormap .text.ClosestColor .text.Riemersma .text.RiemersmaDither)
. = ALIGN(0x1000);
*(.text.RemapImage)
. = ALIGN(0x1000);
*(.text.LevelColorsImageChannel)
. = ALIGN(0x1000);
*(.text.LevelizeImageChannel)
. = ALIGN(0x1000);
*(.text.LevelImageChannel)
. = ALIGN(0x1000);
*(.text.ClampImageChannel)
. = ALIGN(0x1000);
*(.text.ParsePageGeometry)
. = ALIGN(0x1000);
*(.text.CropImage)
. = ALIGN(0x1000);
*(.text.StringToList)
. = ALIGN(0x1000);
*(.text.FormatMagickTime .text.PrintStringInfo .text.ReadImage .text.IsHistogramImage .text.GetNumberColors .text.IdentifyImage .text.PrintChannelLocations .text.PrintChannelMoments .text.PrintChannelPerceptualHash .text.PrintChannelFeatures)
. = ALIGN(0x1000);
*(.text.CloneImages)
. = ALIGN(0x1000);
*(.text.GetImageChannelFeatures)
. = ALIGN(0x1000);
*(.text.GetImageChannelMoments .text.GetImageChannelPerceptualHash)
. = ALIGN(0x1000);
*(.text.GetImageHistogram .text.DefineImageHistogram)
. = ALIGN(0x1000);
*(.text.GetImageTotalInkDensity)
. = ALIGN(0x1000);
*(.text.MorphologyApply)
. = ALIGN(0x1000);
*(.text.BlobToFile .text.BlobToImage)
. = ALIGN(0x1000);
*(.text.SetImageClipMask)
. = ALIGN(0x1000);
*(.text.NegateImageChannel)
. = ALIGN(0x1000);
*(.text.ClipImagePath)
. = ALIGN(0x1000);
*(.text.BilevelImageChannel)
. = ALIGN(0x1000);
*(.text.SeparateImageChannel)
. = ALIGN(0x1000);
*(.text.AcquireNextImage)
. = ALIGN(0x1000);
*(.text.MagickWandTerminus)
. = ALIGN(0x1000);
*(.text.GetExceptionInfo)
. = ALIGN(0x1000);
*(.text.SetImageOption)
. = ALIGN(0x1000);
*(.text.ProfileImage)
. = ALIGN(0x1000);
*(.text.ReduceImageColors .text.QuantizeErrorFlatten .text.Reduce .text.QuantizeImage)
. = ALIGN(0x1000);
*(.text.ListThresholdMapFile .text.ListThresholdMaps .text.GetTypeInfoList .text.ListTypeInfo .text.DefineImageRegistry .text.ListMagickResourceInfo .text.GetCoderInfoList .text.ListCoderInfo .text.GetColorInfoList .text.ListColorInfo .text.ListConfigureInfo .text.GetLocaleInfoList .text.ListLocaleInfo .text.GetMagicInfoList .text.ListMagicInfo .text.GetMagickInfoList .text.SetMagickPrecision .text.ListMagickInfo .text.DefineImageOption .text.ParseChannelOption .text.GetPolicyInfoList .text.ListPolicyInfo .text.GetMimeInfoList .text.ListMimeInfo .text.MogrifyImageInfo)
. = ALIGN(0x1000);
*(.text.GetTypeInfo .text.LoadTypeCache)
. = ALIGN(0x1000);
*(.text.GetConfigureInfo .text.LoadConfigureCache)
. = ALIGN(0x1000);
*(.text.GetConfigureInfoList)
. = ALIGN(0x1000);
*(.text.GetXMLTreeAttribute)
. = ALIGN(0x1000);
*(.text.AcquireMimeCache .text.LoadMimeCache)
. = ALIGN(0x1000);
*(.text.GetCoderInfo .text.LoadCoderCache)
. = ALIGN(0x1000);
*(.text.ExpandFilename .text.ExpandFilenames .text.ListFiles)
. = ALIGN(0x1000);
*(.text.PerceptibleImageChannel)
. = ALIGN(0x1000);
*(.text.AdaptiveThresholdImage)
. = ALIGN(0x1000);
*(.text.AppendImages)
. = ALIGN(0x1000);
*(.text.AutoGammaImageChannel)
. = ALIGN(0x1000);
*(.text.BlackThresholdImageChannel)
. = ALIGN(0x1000);
*(.text.BlueShiftImage)
. = ALIGN(0x1000);
*(.text.ChopImage)
. = ALIGN(0x1000);
*(.text.CoalesceImages)
. = ALIGN(0x1000);
*(.text.ColorDecisionListImage)
. = ALIGN(0x1000);
*(.text.ColorizeImage)
. = ALIGN(0x1000);
*(.text.CombineImages)
. = ALIGN(0x1000);
*(.text.CompositeLayers)
. = ALIGN(0x1000);
*(.text.CycleColormapImage)
. = ALIGN(0x1000);
*(.text.RelinquishMagickResource .text.DeskewImage .text.RadonProjection .text.AcquireMatrixInfo .text.DestroyMatrixInfo .text.GetMatrixElement)
. = ALIGN(0x1000);
*(.text.EmbossImage)
. = ALIGN(0x1000);
*(.text.EnhanceImage)
. = ALIGN(0x1000);
*(.text.InterpolativeResizeImage)
. = ALIGN(0x1000);
*(.text.PolynomialImageChannel)
. = ALIGN(0x1000);
*(.text.CompareImageChannels)
. = ALIGN(0x1000);
*(.text.MinMaxStretchImage)
. = ALIGN(0x1000);
*(.text.ClutImageChannel)
. = ALIGN(0x1000);
*(.text.EqualizeImageChannel)
. = ALIGN(0x1000);
*(.text.AdaptiveBlurImageChannel)
. = ALIGN(0x1000);
*(.text.AdaptiveSharpenImageChannel)
. = ALIGN(0x1000);
*(.text.AddNoiseImageChannel)
. = ALIGN(0x1000);
*(.text.EvaluateImageChannel)
. = ALIGN(0x1000);
*(.text.CompareImageLayers)
. = ALIGN(0x1000);
*(.text.ExtentImage)
. = ALIGN(0x1000);
*(.text.FilterImageChannel)
. = ALIGN(0x1000);
*(.text.FlipImage)
. = ALIGN(0x1000);
*(.text.FunctionImageChannel .text.ApplyFunction)
. = ALIGN(0x1000);
*(.text.FxImageChannel)
. = ALIGN(0x1000);
*(.text.GetMeanSquaredDistortion)
. = ALIGN(0x1000);
*(.text.GetPerceptualHashDistortion)
. = ALIGN(0x1000);
*(.text.GetPeakSignalToNoiseRatio)
. = ALIGN(0x1000);
*(.text.GetPeakAbsoluteDistortion)
. = ALIGN(0x1000);
*(.text.GetNormalizedCrossCorrelationDistortion)
. = ALIGN(0x1000);
*(.text.GetMeanErrorPerPixel)
. = ALIGN(0x1000);
*(.text.GetMeanAbsoluteDistortion)
. = ALIGN(0x1000);
*(.text.GetFuzzDistortion)
. = ALIGN(0x1000);
*(.text.GetAbsoluteDistortion)
. = ALIGN(0x1000);
*(.text.GetImageChannelDistortion .text.FormatImageProperty)
. = ALIGN(0x1000);
*(.text.HaldClutImageChannel)
. = ALIGN(0x1000);
*(.text.LinearStretchImage)
. = ALIGN(0x1000);
*(.text.MagnifyImage)
. = ALIGN(0x1000);
*(.text.MorphImages)
. = ALIGN(0x1000);
*(.text.MorphologyImageChannel .text.ShowKernelInfo)
. = ALIGN(0x1000);
*(.text.UnityAddKernelInfo)
. = ALIGN(0x1000);
*(.text.OptimizeLayerFrames)
. = ALIGN(0x1000);
*(.text.CompareImageBounds)
. = ALIGN(0x1000);
*(.text.OptimizeImageTransparency)
. = ALIGN(0x1000);
*(.text.FormatMagickCaption .text.GetNextUTFCode .text.PolaroidImage)
. = ALIGN(0x1000);
*(.text.FlopImage)
. = ALIGN(0x1000);
*(.text.PosterizeImageChannel)
. = ALIGN(0x1000);
*(.text.PreviewImage)
. = ALIGN(0x1000);
*(.text.OilPaintImage)
. = ALIGN(0x1000);
*(.text.MontageImageList)
. = ALIGN(0x1000);
*(.text.CloneMontageInfo .text.GetMontageInfo)
. = ALIGN(0x1000);
*(.text.ModulateImage)
. = ALIGN(0x1000);
*(.text.ImplodeImage)
. = ALIGN(0x1000);
*(.text.GammaImageChannel)
. = ALIGN(0x1000);
*(.text.DespeckleImage)
. = ALIGN(0x1000);
*(.text.GrayscaleImage .text.CharcoalImage)
. = ALIGN(0x1000);
*(.text.QuantizeImages)
. = ALIGN(0x1000);
*(.text.RaiseImage)
. = ALIGN(0x1000);
*(.text.GetThresholdMapFile .text.GetThresholdMap .text.OrderedPosterizeImageChannel)
. = ALIGN(0x1000);
*(.text.RandomThresholdImageChannel)
. = ALIGN(0x1000);
*(.text.ResetImagePage)
. = ALIGN(0x1000);
*(.text.RollImage .text.CopyImageRegion)
. = ALIGN(0x1000);
*(.text.RotateImage)
. = ALIGN(0x1000);
*(.text.DistortImage .text.DistortResizeImage)
. = ALIGN(0x1000);
*(.text.IntegralRotateImage)
. = ALIGN(0x1000);
*(.text.ScaleImage)
. = ALIGN(0x1000);
*(.text.InitializeHistogram)
. = ALIGN(0x1000);
*(.text.OptimalTau .text.InitializeList .text.Stability .text.MeanStability .text.ActiveNodes .text.FreeNodes)
. = ALIGN(0x1000);
*(.text.SegmentImage)
. = ALIGN(0x1000);
*(.text.SelectiveBlurImageChannel)
. = ALIGN(0x1000);
*(.text.SepiaToneImage)
. = ALIGN(0x1000);
*(.text.ContrastImage)
. = ALIGN(0x1000);
*(.text.SetImageAlphaChannel)
. = ALIGN(0x1000);
*(.text.SetImageChannelDepth)
. = ALIGN(0x1000);
*(.text.SetImageType)
. = ALIGN(0x1000);
*(.text.SetPixelCacheVirtualMethod .text.SetCacheAlphaChannel)
. = ALIGN(0x1000);
*(.text.ShadeImage)
. = ALIGN(0x1000);
*(.text.ShadowImage)
. = ALIGN(0x1000);
*(.text.SharpenImageChannel)
. = ALIGN(0x1000);
*(.text.FrameImage)
. = ALIGN(0x1000);
*(.text.YShearImage)
. = ALIGN(0x1000);
*(.text.XShearImage)
. = ALIGN(0x1000);
*(.text.ShearImage)
. = ALIGN(0x1000);
*(.text.SigmoidalContrastImageChannel)
. = ALIGN(0x1000);
*(.text.SketchImage)
. = ALIGN(0x1000);
*(.text.ContrastStretchImageChannel)
. = ALIGN(0x1000);
*(.text.EdgeImage)
. = ALIGN(0x1000);
*(.text.MotionBlurImageChannel)
. = ALIGN(0x1000);
*(.text.SmushImages)
. = ALIGN(0x1000);
*(.text.SolarizeImageChannel)
. = ALIGN(0x1000);
*(.text.SparseColorImage)
. = ALIGN(0x1000);
*(.text.GenerateCoefficients .text.InvertPerspectiveCoefficients .text.poly_basis_fn .text.AcquireMagickMatrix .text.GaussJordanElimination .text.LeastSquaresAddTerms)
. = ALIGN(0x1000);
*(.text.SpliceImage)
. = ALIGN(0x1000);
*(.text.SpreadImage)
. = ALIGN(0x1000);
*(.text.StripImage)
. = ALIGN(0x1000);
*(.text.SwirlImage)
. = ALIGN(0x1000);
*(.text.TextureImage)
. = ALIGN(0x1000);
*(.text.SampleImage)
. = ALIGN(0x1000);
*(.text.ThumbnailImage)
. = ALIGN(0x1000);
*(.text.TintImage)
. = ALIGN(0x1000);
*(.text.TransposeImage)
. = ALIGN(0x1000);
*(.text.TransverseImage)
. = ALIGN(0x1000);
*(.text.UniqueImageColors .text.UniqueColorsToImage .text.SetImageProgress)
. = ALIGN(0x1000);
*(.text.AcquireQuantizeInfo)
. = ALIGN(0x1000);
*(.text.UnsharpMaskImageChannel)
. = ALIGN(0x1000);
*(.text.VignetteImage)
. = ALIGN(0x1000);
*(.text.TransformImage)
. = ALIGN(0x1000);
*(.text.Base64Decode .text.AnnotateImage .text.AcquireDrawInfo .text.ReadInlineImage .text.DrawAffineImage .text.DrawClipPath .text.DrawImage .text.DrawPatternPath .text.TraceBezier .text.DrawPrimitive .text.DrawPolygonPrimitive .text.DrawStrokePolygon .text.DestroyPolygonThreadSet .text.DrawGradientImage .text.GradientImage)
. = ALIGN(0x1000);
*(.text.WaveImage)
. = ALIGN(0x1000);
*(.text.WhiteThresholdImageChannel)
. = ALIGN(0x1000);
*(.text.WriteImages)
. = ALIGN(0x1000);
*(.text.WriteImage .text.IsTaintImage .text.SyncImageProfiles)
. = ALIGN(0x1000);
*(.text.GetTypeInfoByFamily .text.RenderType .text.RenderFreetype)
. = ALIGN(0x1000);
*(.text.CropImageToTiles .text.ParseGravityGeometry)
. = ALIGN(0x1000);
*(.text.GetDrawInfo .text.CloneDrawInfo)
. = ALIGN(0x1000);
*(.text.DestroyDrawInfo)
. = ALIGN(0x1000);
*(.text.AcquireTokenInfo .text.Tokenizer .text.AutoOrientImage .text.analyzeImage .text.SeparateImages .text.ParseAffineGeometry .text.ReadImages .text.GetCommandOptionFlags .text.CannyEdgeImage .text.HoughLineImage .text.MeanShiftImage .text.ComplexImages .text.SetImageMask .text.DisposeImages .text.RemoveDuplicateLayers .text.RemoveZeroDelayLayers .text.DeleteImages .text.MatrixToImage .text.InvokeDynamicImageFilter .text.MogrifyImage .text.GetImageCache .text.MogrifyImages .text.MogrifyImageList)
. = ALIGN(0x1000);
*(.text.PingImage)
. = ALIGN(0x1000);
*(.text.MagickRealTypeCompare)
. = ALIGN(0x1000);
*(.text.DestroyRegistryNode)
. = ALIGN(0x1000);
*(.text.Jinc)
. = ALIGN(0x1000);
*(.text.Gaussian)
. = ALIGN(0x1000);
*(.text.Kaiser)
. = ALIGN(0x1000);
*(.text.CubicBC)
. = ALIGN(0x1000);
*(.text.Box)
. = ALIGN(0x1000);
*(.text.Sinc)
. = ALIGN(0x1000);
*(.text.SincFast)
. = ALIGN(0x1000);
*(.text.Triangle)
. = ALIGN(0x1000);
*(.text.Hanning)
. = ALIGN(0x1000);
*(.text.Hamming)
. = ALIGN(0x1000);
*(.text.Blackman)
. = ALIGN(0x1000);
*(.text.Quadratic)
. = ALIGN(0x1000);
*(.text.Welsh)
. = ALIGN(0x1000);
*(.text.Bohman)
. = ALIGN(0x1000);
*(.text.Lagrange)
. = ALIGN(0x1000);
*(.text.Cosine)
. = ALIGN(0x1000);
*(.text.DestroyTemporaryResources)
. = ALIGN(0x1000);
*(.text.GetVirtualIndexesFromStream)
. = ALIGN(0x1000);
*(.text.GetAuthenticPixelsStream)
. = ALIGN(0x1000);
*(.text.SyncAuthenticPixelsStream)
. = ALIGN(0x1000);
*(.text.GetAuthenticPixelsFromStream)
. = ALIGN(0x1000);
*(.text.GetAuthenticIndexesFromStream)
. = ALIGN(0x1000);
*(.text.GetOneVirtualPixelFromStream)
. = ALIGN(0x1000);
*(.text.GetVirtualPixelStream)
. = ALIGN(0x1000);
*(.text.GetOneAuthenticPixelFromStream)
. = ALIGN(0x1000);
*(.text.QueueAuthenticPixelsStream)
. = ALIGN(0x1000);
*(.text.DestroyPixelStream)
. = ALIGN(0x1000);
*(.text.CacheSignalHandler)
. = ALIGN(0x1000);
*(.text.PingStream)
. = ALIGN(0x1000);
*(.text.GetVirtualPixelCache)
. = ALIGN(0x1000);
*(.text.GetVirtualPixelsCache)
. = ALIGN(0x1000);
*(.text.GetVirtualIndexesFromCache)
. = ALIGN(0x1000);
*(.text.GetOneVirtualPixelFromCache)
. = ALIGN(0x1000);
*(.text.GetAuthenticPixelsCache)
. = ALIGN(0x1000);
*(.text.GetAuthenticIndexesFromCache)
. = ALIGN(0x1000);
*(.text.GetAuthenticPixelsFromCache)
. = ALIGN(0x1000);
*(.text.GetOneAuthenticPixelFromCache)
. = ALIGN(0x1000);
*(.text.QueueAuthenticPixelsCache)
. = ALIGN(0x1000);
*(.text.SyncAuthenticPixelsCache)
. = ALIGN(0x1000);
*(.text.AcquirePixelCacheNexus)
. = ALIGN(0x1000);
*(.text.CloneString)
. = ALIGN(0x1000);
*(.text.CloneImageProperties)
. = ALIGN(0x1000);
*(.text.AcquirePixelCache)
. = ALIGN(0x1000);
*(.text.CloneBlobInfo)
. = ALIGN(0x1000);
*(.text.CloneImageArtifacts .text.CloneImage .text.CloneImageProfiles)
. = ALIGN(0x1000);
*(.text.Ascii85Initialize)
. = ALIGN(0x1000);
*(.text.GetPolicyInfo .text.LoadPolicyCache)
. = ALIGN(0x1000);
*(.text.GetConfigureOptions)
. = ALIGN(0x1000);
*(.text.InterpretSiPrefixValue)
. = ALIGN(0x1000);
*(.text.ParseCommandOption)
. = ALIGN(0x1000);
*(.text.GetPageGeometry)
. = ALIGN(0x1000);
*(.text.GetGeometry)
. = ALIGN(0x1000);
*(.text.AcquireVirtualCacheView)
. = ALIGN(0x1000);
*(.text.ConcatenateString)
. = ALIGN(0x1000);
*(.text.GetMagickInfo)
. = ALIGN(0x1000);
*(.text.RegisterTGAImage .text.SetMagickInfo .text.RegisterMagickInfo)
. = ALIGN(0x1000);
*(.text.WriteTo8BimProfile)
. = ALIGN(0x1000);
*(.text.ConvertHSLToRGB)
. = ALIGN(0x1000);
*(.text.GetMagicInfo .text.LoadMagicCache)
. = ALIGN(0x1000);
*(.text.SeekBlob)
. = ALIGN(0x1000);
*(.text.StringToArgv .text.GlobExpression .text.GetNextUTFCode.4869 .text.ExcerptImage .text.GetImageRegistry .text.AcquireResizeFilter .text.ResizeImage .text.HorizontalFilter .text.VerticalFilter .text.GetPathTemplate .text.AcquireUniqueFileResource .text.GetImageChannelKurtosis .text.GetImageChannelMean .text.GetImageChannelStatistics .text.GetImageChannelDepth .text.QueueAuthenticPixelCacheNexus .text.ReadPixelCachePixels .text.ReadPixelCacheIndexes .text.GetImagePixelCache .text.SetPixelCacheNexusPixels .text.OpenPixelCache .text.ClonePixelCacheRepository .text.WritePixelCachePixels .text.WritePixelCacheIndexes .text.ImageToFile .text.OpenBlob .text.AcquireDistributeCacheInfo .text.GetVirtualPixelsFromNexus .text.SyncAuthenticPixelCacheNexus .text.GetColorCompliance .text.LoadColorCache .text.QueryMagickColorCompliance .text.QueryColorCompliance .text.QueryMagickColorname .text.CloneImageOptions .text.CloneMagickPixelPacket .text.GetPixelIntensity .text.InterpolateMagickPixelPacket .text.IsRightsAuthorized .text.AcquireFxInfo .text.DestroyFxInfo .text.FxEvaluateSubexpression .text.FxGetSymbol .text.FxChannelStatistics .text.ConvertHCLToRGB .text.ConvertHSBToRGB .text.GetImageChannelRange .text.AcquireImage .text.SyncImageSettings .text.AcquireImageInfo .text.CloneImageInfo .text.InterpretImageFilename .text.SetImageInfo .text.SetImageProfileInternal .text.SetImageProperty .text.GetImageProperty)
. = ALIGN(0x1000);
*(.text.ReadBlob)
. = ALIGN(0x1000);
*(.text.EncodePixelGamma)
. = ALIGN(0x1000);
*(.text.DecodePixelGamma)
. = ALIGN(0x1000);
*(.text.SubstituteString)
. = ALIGN(0x1000);
*(.text.DestroyXMLTree)
. = ALIGN(0x1000);
*(.text.InsertTagIntoXMLTree)
. = ALIGN(0x1000);
*(.text.NewXMLTree .text.ParseEntities .text.ValidateEntities .text.ParseProcessingInstructions)
. = ALIGN(0x1000);
*(.text.ConcatenateColorComponent .text.GetColorTuple .text.ConcatentateHexColorComponent .text.GetMagickPrecision)
. = ALIGN(0x1000);
*(.text.GetImageProfile)
. = ALIGN(0x1000);
*(.text.DestroyCacheView)
. = ALIGN(0x1000);
*(.text.FileToBlob)
. = ALIGN(0x1000);
*(.text.TransformSignature)
. = ALIGN(0x1000);
*(.text.UpdateSignature)
. = ALIGN(0x1000);
*(.text.AcquireSignatureInfo)
. = ALIGN(0x1000);
*(.text.FinalizeSignature)
. = ALIGN(0x1000);
*(.text.SetRandomKey .text.IncrementRandomNonce)
. = ALIGN(0x1000);
*(.text.ConcatenateStringInfo)
. = ALIGN(0x1000);
*(.text.SetStringInfoLength)
. = ALIGN(0x1000);
*(.text.AcquireRandomInfo .text.GenerateEntropicChaos)
. = ALIGN(0x1000);
*(.text.DestroyImageInfo)
. = ALIGN(0x1000);
*(.text.DestroyBlob)
. = ALIGN(0x1000);
*(.text.CloseBlob)
. = ALIGN(0x1000);
*(.text.DestroyImage)
. = ALIGN(0x1000);
*(.text.DestroyImagePixelCache)
. = ALIGN(0x1000);
*(.text.AppendImageFormat .text.RelinquishUniqueFileResource)
. = ALIGN(0x1000);
*(.text.DeleteNodeFromSplayTree)
. = ALIGN(0x1000);
*(.text.FormatMagickSize)
. = ALIGN(0x1000);
*(.text.DestroyPixelCache .text.RelinquishPixelCachePixels)
. = ALIGN(0x1000);
*(.text.DestroyCoderNode)
. = ALIGN(0x1000);
*(.text.CoderInfoCompare)
. = ALIGN(0x1000);
*(.text.CoderCompare)
. = ALIGN(0x1000);
*(.text.ColorInfoCompare)
. = ALIGN(0x1000);
*(.text.ColorCompare)
. = ALIGN(0x1000);
*(.text.IntensityCompare)
. = ALIGN(0x1000);
*(.text.ConfigureInfoCompare)
. = ALIGN(0x1000);
*(.text.ConfigureCompare)
. = ALIGN(0x1000);
*(.text.PingStream.850)
. = ALIGN(0x1000);
*(.text.DestroyLocaleNode)
. = ALIGN(0x1000);
*(.text.LocaleFatalErrorHandler)
. = ALIGN(0x1000);
*(.text.LocaleInfoCompare)
. = ALIGN(0x1000);
*(.text.LocaleTagCompare)
. = ALIGN(0x1000);
*(.text.MagicInfoCompare)
. = ALIGN(0x1000);
*(.text.MagicCompare)
. = ALIGN(0x1000);
*(.text.DestroyMagickNode)
. = ALIGN(0x1000);
*(.text.MagickInfoCompare)
. = ALIGN(0x1000);
*(.text.MagickCompare)
. = ALIGN(0x1000);
*(.text.CompareEdges)
. = ALIGN(0x1000);
*(.text.SceneCompare)
. = ALIGN(0x1000);
*(.text.DefaultFatalErrorHandler)
. = ALIGN(0x1000);
*(.text.DefaultErrorHandler)
. = ALIGN(0x1000);
*(.text.DefaultWarningHandler)
. = ALIGN(0x1000);
*(.text.CompareSplayTreeString)
. = ALIGN(0x1000);
*(.text.IntensityCompare.4633)
. = ALIGN(0x1000);
*(.text.HashPointerType)
. = ALIGN(0x1000);
*(.text.HistogramCompare)
. = ALIGN(0x1000);
*(.text.MatrixSignalHandler)
. = ALIGN(0x1000);
*(.text.RelinquishAlignedMemory)
. = ALIGN(0x1000);
*(.text.RelinquishMagickMemory)
. = ALIGN(0x1000);
*(.text.MimeInfoCompare)
. = ALIGN(0x1000);
*(.text.MimeCompare)
. = ALIGN(0x1000);
*(.text.MonitorProgress)
. = ALIGN(0x1000);
*(.text.ParseGeometry)
. = ALIGN(0x1000);
*(.text.DestroyRandomInfo)
. = ALIGN(0x1000);
*(.text.AcquireString .text.AcquireStringInfo .text.ConfigureFileToStringInfo .text.ConstantString .text.FileToXML .text.AllocateSemaphoreInfo .text.ColorComponentTerminus .text.ConfigureComponentTerminus .text.GetConfigurePaths .text.GetLocaleInfo_ .text.GetLocaleOptions .text.LoadLocaleCache .text.MagicComponentTerminus .text.MagickCoreTerminus .text.UnregisterMagickInfo .text.AcquireExceptionInfo .text.GetExceptionMessage .text.ThrowMagickException .text.DestroyExceptionInfo .text.ThrowMagickExceptionList .text.GetLocaleExceptionMessage .text.ThrowException .text.AddValueToSplayTree .text.SplaySplayTree .text.Splay .text.LinkSplayTreeNodes .text.NewSplayTree .text.DeleteNodeByValueFromSplayTree .text.NewLinkedList .text.MimeComponentTerminus .text.PolicyComponentTerminus)
. = ALIGN(0x1000);
*(.text.CatchException)
. = ALIGN(0x1000);
*(.text.DestroySplayTree)
. = ALIGN(0x1000);
*(.text.FormatLocaleString)
. = ALIGN(0x1000);
*(.text.GetMagickToken)
. = ALIGN(0x1000);
*(.text.GetPathComponent)
. = ALIGN(0x1000);
*(.text.FormatLocaleFile)
. = ALIGN(0x1000);
*(.text.DestroyProfile)
. = ALIGN(0x1000);
*(.text.IntensityCompare.4292)
. = ALIGN(0x1000);
*(.text.DestroyAttribute)
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
