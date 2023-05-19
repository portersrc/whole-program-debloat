#http://www.sthda.com/english/wiki/ggplot2-barplots-quick-start-guide-r-software-and-data-visualization#barplot-with-multiple-groups
library(ggplot2)




df <- data.frame(
  # legend=rep(c("Baseline", "Decker"), each=6),
  legend=rep(c("Decker"), each=6),
  bmark=rep(c(
    "3s-wiki",
    "30s-wiki",
    "300s-wiki",
    "1MB-30s",
    "10MB-30s",
    "100MB-300s"
  # ), 2),
  ), 1),
  slowdown=
    c(
      # # base_ls
      # 1,
      # 1,
      # 1,
      # 1,
      # 1,
      # 1,

      # wpd_cl_ics + sc
      1.048034934,
      1.034139403,
      1.067251462,
      1.021578298,
      0.978012685,
      0.986013986
  )
)


head(df)

# To keep the original x axis label order (and avoid R
# shuffling them into alphabetical order in the final graph),
# first turn 'bmark' column into a character vector.
df$bmark <- as.character(df$bmark)
# Then turn it back into a factor with the levels in the correct order
df$bmark <- factor(df$bmark, levels=unique(df$bmark))

ggplot(data=df, aes(x=bmark, y=slowdown, fill=legend)) +
  geom_bar(stat="identity", position=position_dodge(), fill="#00BFC4") +
  geom_hline(yintercept=1, linetype='dotted', col = 'red')+
  theme_minimal() +
  theme(axis.title.y=element_text(size = 15)) +
  theme(legend.text=element_text(size = 15)) +
  theme(axis.text.y=element_text(size = 15)) +
  theme(axis.text.x=element_text(angle = -45, hjust = 0, size = 15)) +
  #ylim(0.9, 2)
  coord_cartesian(ylim = c(0.95, 1.1)) +
  theme(legend.title = element_blank()) +
  theme(legend.position = c(.9,.8)) +
  theme(axis.title.x=element_blank()) +
  ylab("Transfer/sec Degradation")

