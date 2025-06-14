;Header byte follows this format:
;7:     1 = TILE, 0 = MAP
;6:     1 = Uncompressed
;5 & 4: 00 = SCRN, 01 = TALL
;       10 = WIDE, 11 = FULL
;0-3: Unused but set to 1
.DB %11001111

;Size of uncompressed tile data:
.DW $03D0
;Raw tile data 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $01 $01 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $FF $FF 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $FC $FC 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $07 $07 
.DB $02 $03 $04 $07 $0B $0C $0B $0C $13 $1E $11 $1E $21 $3E $E1 $FF 
.DB $00 $FF $00 $FF $19 $E6 $1B $E4 $BB $4C $B3 $4C $F3 $0C $F3 $1C 
.DB $00 $FF $00 $FF $E7 $18 $F7 $08 $F7 $C9 $36 $C9 $36 $C9 $37 $C8 
.DB $04 $FC $04 $FC $C4 $3C $E4 $1C $F4 $CC $34 $CC $34 $CC $E7 $1F 
.DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $F0 $F0 
.DB $07 $07 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 
.DB $E0 $FF $21 $3E $11 $1E $13 $1C $0B $0C $0B $0F $04 $07 $02 $03 
.DB $E3 $1C $F3 $0C $F3 $4C $BB $E4 $1B $E6 $19 $FF $00 $FF $00 $FF 
.DB $37 $C8 $37 $C9 $36 $C9 $F6 $09 $F6 $19 $E6 $FF $00 $FF $00 $FF 
.DB $E7 $1F $F4 $8C $74 $CC $34 $CC $34 $CC $34 $FC $04 $FC $04 $FC 
.DB $FF $FF $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $F0 $F0 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 
.DB $01 $01 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $FC $FC $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $06 $07 $07 
.DB $3F $3F $20 $3F $20 $3F $20 $3F $20 $3F $20 $3F $20 $3F $E0 $FF 
.DB $FF $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF 
.DB $FF $FF $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF 
.DB $FF $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF 
.DB $FF $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF 
.DB $FF $FF $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF 
.DB $FF $FF $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF 
.DB $FF $FF $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF 
.DB $FF $FF $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF 
.DB $E0 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 
.DB $07 $07 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
.DB $E0 $FF $20 $3F $20 $3F $20 $3F $20 $3F $20 $3F $20 $3F $3F $3F 
.DB $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $FF $FF 
.DB $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF $40 $FF $FF $FF 
.DB $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $FF $FF 
.DB $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $FF $FF 
.DB $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF $02 $FF $FF $FF 
.DB $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF $04 $FF $FF $FF 
.DB $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF $08 $FF $FF $FF 
.DB $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF $10 $FF $FF $FF 
.DB $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $20 $E0 $E0 $E0 
.DB $01 $01 $02 $03 $04 $07 $08 $0F $10 $1F $20 $3F $40 $7F $80 $FF 
.DB $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF $00 $FF 
.DB $80 $80 $40 $C0 $20 $E0 $10 $F0 $08 $F8 $04 $FC $02 $FE $01 $FF 
.DB $80 $FF $40 $7F $20 $3F $10 $1F $08 $0F $04 $07 $02 $03 $01 $01 
.DB $01 $FF $02 $FE $04 $FC $08 $F8 $10 $F0 $20 $E0 $40 $C0 $80 $80 
.DB $FF $FF $E0 $FF $C0 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF 
.DB $FF $FF $07 $FF $03 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF 
.DB $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF 
.DB $00 $FF $00 $FF $3C $C3 $7E $81 $7E $99 $66 $99 $66 $99 $66 $99 
.DB $00 $FF $00 $FF $66 $99 $66 $99 $66 $99 $66 $99 $66 $99 $66 $99 
.DB $00 $FF $00 $FF $7E $81 $7E $81 $7E $E7 $18 $E7 $18 $E7 $18 $E7 
.DB $00 $FF $00 $FF $7C $83 $7E $81 $7F $9C $63 $9C $63 $9C $7F $81 
.DB $00 $FF $00 $FF $60 $9F $60 $9F $60 $9F $60 $FF $00 $FF $00 $FF 
.DB $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF 
.DB $66 $99 $66 $99 $66 $99 $7E $81 $7E $C3 $3C $FF $00 $FF $00 $FF 
.DB $18 $E7 $18 $E7 $18 $E7 $18 $E7 $18 $E7 $18 $FF $00 $FF $00 $FF 
.DB $7E $83 $7C $9F $60 $9F $60 $9F $60 $9F $60 $FF $00 $FF $00 $FF 
.DB $80 $FF $80 $FF $80 $FF $80 $FF $80 $FF $C0 $FF $E0 $FF $FF $FF 
.DB $01 $FF $01 $FF $01 $FF $01 $FF $01 $FF $03 $FF $07 $FF $FF $FF 