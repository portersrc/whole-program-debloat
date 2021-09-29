#http://www.sthda.com/english/wiki/ggplot2-barplots-quick-start-guide-r-software-and-data-visualization#barplot-with-multiple-groups
library(ggplot2)




df <- data.frame(
  legend=rep(c("Baseline", "Decker"), each=15),
  bmark=rep(c(
    "perlbench", 
    "mcf",
    "namd",
    "parest", 
    "povray",
    "lbm",
    "omnetpp", 
    "xalancbmk",
    "x264",
    "blender", 
    "deepsjeng",
    "imagick",
    "leela", 
    "nab",
    "xz"
  ), 2),
  slowdown=
    c(
      # base_ls
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,

      # wpd_cl_ics (todo wpd_cl_ics_sc)
      0.9903420105, # perlbench
      1.011573185, # mcf
      0.9990883179, # namd
      1.024487023, # parest
      1.071922054, # povray
      1.036504238, # lbm
      1.117012653, # omnetpp
      1.085095903, # xalancbmk
      1.029968998, # x264
      1.000281204, # blender
      1.003534296, # deepsjeng
      0.9827746151, # imagick
      1.024797731, #leela
      1.02610419, # nab
      1.051924182 # xz
  )
)


head(df)


ggplot(data=df, aes(x=bmark, y=slowdown, fill=legend)) +
  geom_bar(stat="identity", position=position_dodge()) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle = -45, hjust = 0)) +
  #ylim(0.9, 2)
  coord_cartesian(ylim = c(0.95, 1.12)) +
  theme(legend.title = element_blank()) +
  theme(axis.title.x=element_blank())

