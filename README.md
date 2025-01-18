# Genesis for Analogue Pocket with support for Analogizer-FPGA adapter
* Analogizer V1.0.0   [22/06/2024]: Added initial support for Analogizer adapter (RGBS, RGsB, YPbPr, Y/C, SVGA Scandoubler)
* Analogizer V1.0.1   [23/06/2024]: Fixed truncated last scanline.
* Analogizer V1.0.2   [19/01/2025]: Added PSX digital/DS/DS2 SNAC support (SCPH-1010, SPCH-1080,SCPH-1180, SCPH-1200, SCPH-10010 and clones). Fixed video output.
  
  Adapted to Analogizer by [@RndMnkIII](https://github.com/RndMnkIII) based on **ericlewis** Genesis for Analogue Pocket Core.

| Video output | Status | SOG Switch(Only R2,R3 Analogizer) |
| :----------- | :----: | :-------------------------------: |     
| RGBS         |  ✅    |     Off                           |
| RGsB         |  ✅    |     On                            |
| YPbPr*       |  ✅🔹  |     On                            |
| Y/C NTSC*    |  ✅    |     Off                           |
| Y/C PAL*     |  ✅    |     Off                           |
| Scandoubler  |  ✅    |     Off                           |

🔹 Tested with Sony PVM-9044D

| :video_game:            | Analogizer A/B config Switch | Status |
| :---------------------- | :--------------------------- | :----: |
| DB15                    | A                            |  ✅    |
| NES                     | A                            |  ✅    |
| SNES                    | A                            |  ✅    |
| PCENGINE                | A                            |  ✅    |
| PCE MULTITAP            | A                            |  ✅    |
| PSX DS/DS2 Digital DPAD | B                            |  ✅    |
| PSX DS/DS2 Analog  DPAD | B                            |  ✅    |

The Analogizer interface allow to mix game inputs from compatible SNAC gamepads supported by Analogizer (DB15 Neogeo, NES, SNES, PCEngine, PSX) with Analogue Pocket built-in controls or from Dock USB or wireless supported controllers (Analogue support).

All Analogizer adapter versions (v1, v2 and v3) has a side slide switch labeled as 'A B' that must be configured based on the used SNAC game controller.
For example for use it with PSX Dual Shock or Dual Shock 2 native gamepad you must position the switch lever on the B side position. For the remaining
game controllers you must switch the lever on the A side position. 
Be careful when handling this switch. Use something with a thin, flat tip such as a precision screwdriver with a 2.0mm flat blade for example. Place the tip on the switch lever and press gently until it slides into the desired position:
```
     ---
   B|O  |A  A/B switch on position B
     ---   
     ---
   B|  O|A  A/B switch on position A
     ---
``` 

The following options exist in the core menu to configure Analogizer:
* **SNAC Adapter** List: None, DB15,NES,SNES,PCE,PCE Multitap, SNES swap A,B<->X,Y buttons, PSX (Digital DPAD), PSX (Analog DPAD), PSX (P1 Lightgun). The Lightgun option uses PSX Analogic stick as SNES Lightgun aiming track.
* **SNAC Controller Assignment** List: several options about how to map SNAC controller to Pocket controls. The controls not mapped to SNAC by default will map to Pocket connected controllers (Pocket built-in or Dock).
* **Analogizer Video Out** List: you can choose between RGBS (VGA to SCART), RGsB (works is a PVM as YPbPr but using RGB color space), YPbPr (for TV with component video input),
Y/C NTSC or PAL (for SVideo o compositive video using Y/C Active adapter by Mike S11), RGBHV for SVGA monitor Scandouble video output.

**Analogizer** is responsible for generating the correct encoded Y/C signals from RGB and outputs to R,G pins of VGA port. Also redirects the CSync to VGA HSync pin.
The required external Y/C adapter that connects to VGA port is responsible for output Svideo o composite video signal using his internal electronics. Oficially
only the Mike Simone Y/C adapters (active) designs will be supported by Analogizer and will be the ones to use.

Support native PCEngine/TurboGrafx-16 2btn, 6 btn gamepads and 5 player multitap using SNAC adapter
and PC Engine cable harness (specific for Analogizer). Many thanks to [Mike Simone](https://github.com/MikeS11/MiSTerFPGA_YC_Encoder) for his great Y/C Encoder project.

For output Y/C and composite video you need to select in Pocket's Menu: `Analogizer Video Out > Y/C NTSC` or `Analogizer Video Out > Y/C NTSC,Pocket OFF` for NTSC. You need to select in Pocket's Menu: `Analogizer Video Out > Y/C PAL` or `Analogizer Video Out > Y/C PAL,Pocket OFF` for PAL.

For output Scandoubler SVGA video you need to select in Pocket's Menu: `Analogizer Video Out > Scandoubler RGBHV`.

You will need to connect an active VGA to Y/C adapter to the VGA port (the 5V power is provided by VGA pin 9). I'll recomend one of these (active):
* [MiSTerAddons - Active Y/C Adapter](https://misteraddons.com/collections/parts/products/yc-active-encoder-board/)
* [MikeS11 Active VGA to Composite / S-Video](https://ultimatemister.com/product/mikes11-active-composite-svideo/)
* [Active VGA->Composite/S-Video adapter](https://antoniovillena.com/product/mikes1-vga-composite-adapter/)

Using another type of Y/C adapter not tested to be used with Analogizer will not receive official support.

=========================================================================================================


This is a port of a mister port of the [fpgagen](https://github.com/Torlus/fpgagen) core for Analogue Pocket.
I am sure I am forgetting something else here... I know some JT and Kitrinx modules are used. So, shout out to them.

- Various modules by [Jotego](https://www.patreon.com/topapate) are used
- Composite mode module is by [Kitrinx](https://github.com/Kitrinx)
- Many improvements from [sorgelig](https://github.com/sorgelig)
- Many improvements from [srg320](https://github.com/srg320)
- Various modules by [agg23](https://github.com/agg23)
- Special thanks to [tpwrules](https://github.com/tpwrules)

fpgagen - a SEGA Megadrive/Genesis clone in a FPGA.
Copyright (c) 2010-2013 Gregory Estrade (greg@torlus.com)
All rights reserved

## Important to read this first!
- This core is far from complete and I am aware of most issues.
- No PAL.