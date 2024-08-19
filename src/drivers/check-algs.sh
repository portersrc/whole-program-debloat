#!/bin/bash
cat ds-top.txt | cut -d' ' -f 2- | sort | perl -lape '$_ = qq/@{[sort @F]}/' &> outch-t
cat ds-bot.txt | cut -d' ' -f 2- | sort | perl -lape '$_ = qq/@{[sort @F]}/' &> outch-b
diff outch-t outch-b
