;Header byte follows this format:
;7:     1 = TILE, 0 = MAP
;6:     1 = Uncompressed
;5 & 4: 00 = SCRN, 01 = TALL
;       10 = WIDE, 11 = FULL
;0-3: Unused but set to 1
.DB %11001111

;Size of uncompressed tile data:
.DW $0020
;Raw tile data 
.DB $00 $00 $00 $00 $18 $18 $24 $3C $42 $7E $81 $FF $81 $FF $E7 $FF 
.DB $24 $3C $24 $3C $24 $3C $24 $3C $24 $3C $24 $3C $3C $3C $00 $00 