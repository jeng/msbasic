ca65 -D cbmbasic2 msbasic.s -o tmp/cbmbasic2 -l tmp/cbmbasic2.list
ld65 -C cbmbasic2.cfg tmp/cbmbasic2 -o tmp/cbmbasic.bin -Ln tmp/cbmbasic2.lbl

