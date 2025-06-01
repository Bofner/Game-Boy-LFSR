;Header byte follows this format:
;7:     1 = TILE, 0 = MAP
;6:     1 = Uncompressed
;5 & 4: 00 = SCRN, 01 = TALL
;       10 = WIDE, 11 = FULL
;0-3: Unused but set to 1
.DB %00001111
;Compressed tile data in the form $RunLength + $TileID written as a word ($RLID).
.DW $0100 $0101 $0202 $0103 $0F00 $0104 $0105 $0106 $0107 $0108 $0D02 $0109 $0100 $010A $010B $010C 
.DW $010D $010E $0D0F $0110 $0100 $0111 $0112 $020F $0113 $0F00 $0114 $0302 $0115 $0116 $0117 $0116 
.DW $0118 $0119 $0116 $011A $0116 $011B $0116 $011C $0116 $011D $0116 $011E $011F $030F $0120 $0121 
.DW $0122 $0121 $0123 $0124 $0121 $0125 $0121 $0126 $0121 $0127 $0121 $0128 $0121 $0129 $3100 $0302 
.DW $1000 $012A $032B $012C $0F00 $012D $032B $012E $1000 $030F $3000 $012F $1216 $0130 $0131 $0132 
.DW $0133 $0134 $0135 $0133 $0134 $0136 $0B2B $0137 $0131 $0238 $0139 $013A $0138 $0139 $0136 $0B2B 
.DW $0137 $013B $1221 $013C 
;Terminator word is $0000 since we can't have a run length of length 0.
.DW $0000
