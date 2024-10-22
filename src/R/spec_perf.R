#http://www.sthda.com/english/wiki/ggplot2-barplots-quick-start-guide-r-software-and-data-visualization#barplot-with-multiple-groups
library(ggplot2)




df <- data.frame(
  legend=rep(c("ARTD"), each=16),
  bmark=rep(c(
    "perlbench", 
    "gcc",
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
  # ), 2),
  ), 1),
  slowdown=
    c(
      # artd_release
      1.151149972,
      1.255446818,
      1.089307389,
      0.9725246969,
      0.9901314488,
      1.150307284,
      1.016685525,
      1.223465965,
      1.156748286,
      1.121568822,
      1.040528503,
      0.9899329116,
      1.042722421,
      0.9955339443,
      0.990014574,
      1.018175077
  )
)


head(df)

# To keep the original x axis label order (and avoid R
# shuffling them into alphabetical order in the final graph),
# first turn 'bmark' column into a character vector.
df$bmark <- as.character(df$bmark)
# Then turn it back into a factor with the levels in the correct order
df$bmark <- factor(df$bmark, levels=unique(df$bmark))

# 2022.10.20: Not sure why reducing to a single group (without bars for the
# baseline) led to no more legend? Seems to happen once I use the fill=<color>
# option for geom_bar().
# Also, I'm going to use a 917 x 536 resolution to match old graphs.
ggplot(data=df, aes(x=bmark, y=slowdown, fill=legend)) +
  geom_bar(stat="identity", position=position_dodge(), fill="#00BFC4") +
  geom_hline(yintercept=1, linetype='dotted', col = 'red')+
  theme_minimal() +
  theme(axis.title.y=element_text(size = 15)) +
  theme(legend.text=element_text(size = 15)) +
  theme(axis.text.y=element_text(size = 15)) +
  theme(axis.text.x=element_text(angle = -45, hjust = 0, size = 15)) +
  #ylim(0.9, 2)
  coord_cartesian(ylim = c(0.95, 1.30)) +
  theme(legend.title = element_blank()) +
  theme(legend.position = c(.9,.8)) +
  theme(axis.title.x=element_blank()) +
  ylab("Slowdown")

