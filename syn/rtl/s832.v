module s832(
  blif_clk_net,
  blif_reset_net,
  G0,
  G1,
  G2,
  G3,
  G4,
  G5,
  G6,
  G7,
  G8,
  G9,
  G10,
  G11,
  G12,
  G13,
  G14,
  G15,
  G16,
  G18,
  G327,
  G325,
  G300,
  G322,
  G45,
  G312,
  G53,
  G49,
  G47,
  G296,
  G290,
  G292,
  G298,
  G288,
  G315,
  G55,
  G43,
  G310,
  G302);
input blif_clk_net;
input blif_reset_net;
input G0;
input G1;
input G2;
input G3;
input G4;
input G5;
input G6;
input G7;
input G8;
input G9;
input G10;
input G11;
input G12;
input G13;
input G14;
input G15;
input G16;
input G18;
output G327;
output G325;
output G300;
output G322;
output G45;
output G312;
output G53;
output G49;
output G47;
output G296;
output G290;
output G292;
output G298;
output G288;
output G315;
output G55;
output G43;
output G310;
output G302;
reg G38;
reg G39;
reg G40;
reg G41;
reg G42;
wire G178;
wire G50;
wire G260;
wire G167;
wire G228;
wire G196;
wire G234;
wire G291;
wire G138;
wire G61;
wire G140;
wire G161;
wire G217;
wire G209;
wire G301;
wire G200;
wire G254;
wire G77;
wire G93;
wire G191;
wire G105;
wire G144;
wire G295;
wire G313;
wire G270;
wire G329;
wire G134;
wire G218;
wire G269;
wire G147;
wire G83;
wire G122;
wire G80;
wire G297;
wire G117;
wire G151;
wire G65;
wire G81;
wire G58;
wire G176;
wire G210;
wire G284;
wire G238;
wire G114;
wire G221;
wire G246;
wire G175;
wire G307;
wire G172;
wire G51;
wire G187;
wire G118;
wire G130;
wire G54;
wire G87;
wire G69;
wire G213;
wire G126;
wire G314;
wire G169;
wire G111;
wire G171;
wire G320;
wire G263;
wire G233;
wire G57;
wire G324;
wire G239;
wire G166;
wire G216;
wire G227;
wire G282;
wire G286;
wire G197;
wire G162;
wire G164;
wire G253;
wire G145;
wire G136;
wire G66;
wire G141;
wire G123;
wire G190;
wire G56;
wire G245;
wire G155;
wire G44;
wire G128;
wire G285;
wire G308;
wire G94;
wire G268;
wire G91;
wire G97;
wire G271;
wire G316;
wire G104;
wire G150;
wire G225;
wire G135;
wire G60;
wire G82;
wire G188;
wire G84;
wire G205;
wire G303;
wire G92;
wire G240;
wire G247;
wire G201;
wire G264;
wire G89;
wire G257;
wire G294;
wire G212;
wire G276;
wire G98;
wire G63;
wire G78;
wire G183;
wire G127;
wire G48;
wire G156;
wire G173;
wire G108;
wire G252;
wire G110;
wire G88;
wire G180;
wire G119;
wire G131;
wire G323;
wire G100;
wire G70;
wire G124;
wire G52;
wire G95;
wire G120;
wire G299;
wire G79;
wire G244;
wire G207;
wire G273;
wire G236;
wire G258;
wire G248;
wire G137;
wire G165;
wire G129;
wire G193;
wire G174;
wire G146;
wire G309;
wire G198;
wire G289;
wire G160;
wire G184;
wire G256;
wire G132;
wire G158;
wire G113;
wire G73;
wire G251;
wire G163;
wire G272;
wire G319;
wire G148;
wire G222;
wire G153;
wire G189;
wire G219;
wire G85;
wire G115;
wire G230;
wire G74;
wire G283;
wire G103;
wire G326;
wire G243;
wire G157;
wire G177;
wire G208;
wire G211;
wire G293;
wire G67;
wire G107;
wire G265;
wire G71;
wire G267;
wire G275;
wire G90;
wire G279;
wire G277;
wire G215;
wire G262;
wire G281;
wire G223;
wire G202;
wire G75;
wire G235;
wire G142;
wire G206;
wire G304;
wire G101;
wire G121;
wire G261;
wire G149;
wire G159;
wire G139;
wire G255;
wire G109;
wire G321;
wire G237;
wire G259;
wire G68;
wire G311;
wire G185;
wire G192;
wire G125;
wire G195;
wire G181;
wire G204;
wire G168;
wire G229;
wire G199;
wire G46;
wire G318;
wire G328;
wire G59;
wire G179;
wire G274;
wire G62;
wire G102;
wire G226;
wire G224;
wire G317;
wire G99;
wire G152;
wire G116;
wire G112;
wire G64;
wire G250;
wire G86;
wire G287;
wire G241;
wire G306;
wire G182;
wire G231;
wire G280;
wire G170;
wire G214;
wire G76;
wire G72;
wire G133;
wire G242;
wire G266;
wire G203;
wire G186;
wire G96;
wire G249;
wire G194;
wire G232;
wire G220;
wire G278;
wire G305;
wire G143;
wire G154;
wire G106;
always @(posedge blif_clk_net or posedge blif_reset_net)
  if(blif_reset_net == 1)
    G38 <= 0;
  else
    G38 <= G90;
always @(posedge blif_clk_net or posedge blif_reset_net)
  if(blif_reset_net == 1)
    G39 <= 0;
  else
    G39 <= G93;
always @(posedge blif_clk_net or posedge blif_reset_net)
  if(blif_reset_net == 1)
    G40 <= 0;
  else
    G40 <= G96;
always @(posedge blif_clk_net or posedge blif_reset_net)
  if(blif_reset_net == 1)
    G41 <= 0;
  else
    G41 <= G99;
always @(posedge blif_clk_net or posedge blif_reset_net)
  if(blif_reset_net == 1)
    G42 <= 0;
  else
    G42 <= G102;
assign G178 = ((~G16)&(~G3)&(~G181)&(~G1));
assign G50 = ((~G40)&(~G280));
assign G260 = ((~G263)&(~G264)&(~G265));
assign G167 = (G256&G38&G313);
assign G228 = (G38)|(G313);
assign G196 = ((~G280)&(~G267)&(~G198));
assign G291 = ((~G313))|((~G317))|((~G39))|((~G15));
assign G234 = (G15&G40&G313&G42);
assign G138 = ((~G318)&(~G256));
assign G61 = ((~G328))|((~G313))|((~G317))|((~G146));
assign G140 = ((~G42)&(~G41));
assign G161 = (G3&G42);
assign G301 = ((~G281))|((~G3))|((~G323))|((~G119));
assign G217 = ((~G236))|((~G237));
assign G209 = ((~G328)&(~G313)&(~G317));
assign G200 = (G256&G38&G313);
assign G254 = ((~G318)&(~G256));
assign G77 = ((~G210)&(~G211));
assign G93 = (G92&G91);
assign G191 = (G42&G313);
assign G105 = ((~G328))|((~G40))|((~G15))|((~G9));
assign G144 = (G16)|(G42);
assign G295 = ((~G41))|((~G317))|((~G39))|((~G256));
assign G313 = ((~G41));
assign G270 = ((~G42)&(~G313)&(~G40));
assign G329 = ((~G313))|((~G317))|((~G39))|((~G15));
assign G134 = (G280)|(G42);
assign G218 = (G2&G323&G216&G217);
assign G269 = ((~G114))|((~G115))|((~G116))|((~G317));
assign G147 = ((~G38)&(~G281)&(~G267));
assign G83 = ((~G258)&(~G259)&(~G261));
assign G297 = ((~G41))|((~G40))|((~G39))|((~G280));
assign G122 = ((~G267)&(~G123));
assign G80 = (G38)|(G76);
assign G117 = (G1&G280&G39&G313);
assign G151 = (G38&G16&G256&G153);
assign G65 = ((~G42))|((~G41))|((~G317));
assign G81 = ((~G246))|((~G247))|((~G248));
assign G58 = ((~G132))|((~G133))|((~G134));
assign G176 = ((~G42))|((~G41))|((~G280))|((~G15));
assign G210 = (G39&G38&G245&G209);
assign G310 = ((~G328)&(~G311));
assign G284 = ((~G42))|((~G313));
assign G238 = (G14)|(G267)|(G40)|(G42);
assign G325 = ((~G328)&(~G326));
assign G114 = (G267)|(G318)|(G328);
assign G221 = ((~G226)&(~G227));
assign G302 = ((~G307))|((~G308))|((~G309))|((~G306));
assign G246 = (G4)|(G39);
assign G307 = (G328)|(G313)|(G39)|(G303);
assign G175 = (G317&G176);
assign G172 = ((~G11));
assign G51 = ((~G127)&(~G128)&(~G129));
assign G187 = (G5&G313&G328);
assign G118 = (G245&G38&G39);
assign G130 = ((~G5));
assign G54 = ((~G41))|((~G317))|((~G318))|((~G280));
assign G87 = (G281)|(G83);
assign G69 = ((~G180))|((~G328))|((~G317))|((~G179));
assign G213 = (G16&G313&G328);
assign G314 = ((~G40))|((~G39))|((~G280))|((~G16));
assign G126 = (G10)|(G11);
assign G169 = (G172&G168);
assign G300 = ((~G42)&(~G41)&(~G40)&(~G301));
assign G111 = (G15)|(G42);
assign G47 = ((~G42)&(~G41)&(~G48));
assign G320 = (G40)|(G39)|(G38)|(G316);
assign G171 = ((~G10));
assign G263 = (G39&G38&G262);
assign G233 = (G15&G318);
assign G324 = ((~G120)&(~G121));
assign G57 = ((~G41))|((~G40))|((~G318))|((~G16));
assign G239 = (G40)|(G41)|(G42);
assign G166 = (G245&G38&G41&G42);
assign G312 = ((~G328)&(~G313)&(~G314));
assign G216 = ((~G41)&(~G3));
assign G227 = ((~G242))|((~G243))|((~G244))|((~G40));
assign G282 = (G317&G328);
assign G286 = (G42)|(G313);
assign G162 = (G1&G42);
assign G197 = (G8&G7&G6&G196);
assign G164 = (G42&G313);
assign G253 = ((~G42)&(~G41)&(~G280));
assign G145 = (G16)|(G41);
assign G136 = (G4)|(G281);
assign G66 = ((~G197)&(~G281));
assign G141 = (G317&G16&G323&G140);
assign G123 = ((~G124))|((~G125))|((~G126))|((~G256));
assign G190 = (G41&G42);
assign G56 = ((~G40))|((~G39))|((~G280))|((~G5));
assign G155 = ((~G103)&(~G328)&(~G317)&(~G104));
assign G245 = ((~G0));
assign G44 = ((~G317))|((~G318))|((~G280))|((~G15));
assign G128 = (G280&G318&G40);
assign G308 = (G40)|(G318)|(G16)|(G304);
assign G285 = (G3)|(G2)|(G1)|(G284);
assign G94 = ((~G18));
assign G268 = (G328&G267);
assign G91 = ((~G18));
assign G97 = ((~G18));
assign G271 = (G318&G15&G14&G270);
assign G104 = ((~G117)&(~G118));
assign G316 = ((~G328))|((~G313));
assign G150 = (G256&G147&G148&G149);
assign G225 = ((~G328))|((~G41))|((~G256));
assign G135 = (G280)|(G40);
assign G60 = ((~G158)&(~G159));
assign G82 = ((~G271)&(~G272)&(~G273));
assign G290 = ((~G42)&(~G291));
assign G188 = (G3&G42);
assign G84 = ((~G255))|((~G254));
assign G205 = ((~G228))|((~G229));
assign G303 = ((~G135))|((~G136));
assign G92 = ((~G62))|((~G63))|((~G64))|((~G61));
assign G240 = (G256)|(G313)|(G328);
assign G247 = (G38)|(G318);
assign G201 = ((~G13));
assign G45 = ((~G42)&(~G313)&(~G317)&(~G46));
assign G264 = (G318&G266);
assign G89 = (G150)|(G151)|(G152)|(G155);
assign G257 = ((~G106))|((~G107))|((~G108));
assign G294 = (G16&G293);
assign G212 = ((~G213)&(~G214)&(~G215));
assign G63 = (G40)|(G318)|(G4)|(G59);
assign G276 = (G0&G38&G328);
assign G98 = ((~G78))|((~G79))|((~G80))|((~G77));
assign G55 = ((~G42)&(~G41)&(~G56));
assign G78 = (G39)|(G4)|(G73)|(G74);
assign G183 = (G38)|(G39)|(G41);
assign G127 = (G38&G39&G313&G328);
assign G48 = ((~G40))|((~G39))|((~G280))|((~G130));
assign G156 = ((~G318))|((~G280))|((~G281));
assign G173 = ((~G193)&(~G194));
assign G108 = (G328)|(G15);
assign G252 = (G318&G317);
assign G110 = (G280)|(G42);
assign G88 = ((~G18));
assign G180 = (G41)|(G178);
assign G119 = ((~G39)&(~G38));
assign G131 = ((~G280)&(~G267)&(~G198));
assign G323 = ((~G1));
assign G100 = ((~G18));
assign G70 = (G318)|(G4)|(G65)|(G66);
assign G124 = (G11)|(G12);
assign G52 = (G328)|(G313)|(G39)|(G50);
assign G95 = ((~G70))|((~G71))|((~G72))|((~G69));
assign G120 = (G39&G40&G42);
assign G299 = ((~G318))|((~G280))|((~G15))|((~G14));
assign G315 = ((~G320))|((~G321));
assign G79 = (G40)|(G281)|(G4)|(G75);
assign G244 = (G281)|(G328);
assign G207 = (G202)|(G203)|(G204)|(G205);
assign G273 = (G40&G39&G275);
assign G236 = (G318)|(G317)|(G328);
assign G258 = (G318&G280&G257);
assign G248 = (G245)|(G318);
assign G137 = ((~G42)&(~G41)&(~G280));
assign G165 = ((~G166)&(~G167));
assign G129 = (G39&G317);
assign G193 = (G11&G328);
assign G174 = (G41&G40&G15&G173);
assign G309 = (G39)|(G38)|(G305);
assign G146 = ((~G3)&(~G181)&(~G1)&(~G156));
assign G198 = ((~G9));
assign G289 = ((~G313))|((~G40))|((~G39))|((~G280));
assign G160 = (G5&G313&G328);
assign G184 = ((~G187)&(~G188)&(~G189)&(~G190));
assign G256 = ((~G4));
assign G132 = (G171)|(G11)|(G12)|(G42);
assign G158 = (G280&G157);
assign G113 = (G203)|(G202)|(G112)|(G198);
assign G73 = ((~G42))|((~G41))|((~G40));
assign G163 = (G41&G42);
assign G251 = (G318&G313);
assign G272 = (G318&G4&G274);
assign G43 = ((~G42)&(~G313)&(~G44));
assign G148 = ((~G42)&(~G313)&(~G317)&(~G39));
assign G222 = ((~G234)&(~G235));
assign G319 = ((~G42))|((~G41));
assign G153 = ((~G249)&(~G250)&(~G251)&(~G252));
assign G189 = (G1&G42);
assign G219 = (G318&G220);
assign G85 = (G328)|(G313)|(G317)|(G81);
assign G230 = (G15&G38&G328);
assign G74 = ((~G281)&(~G267)&(~G201));
assign G115 = (G39)|(G42);
assign G283 = (G317&G313);
assign G103 = (G313&G38);
assign G326 = ((~G313))|((~G40))|((~G39))|((~G280));
assign G243 = (G5)|(G41);
assign G49 = ((~G52))|((~G51));
assign G157 = ((~G160)&(~G161)&(~G162)&(~G163));
assign G177 = ((~G195)&(~G280));
assign G208 = (G42)|(G41);
assign G211 = (G317&G39&G256&G212);
assign G293 = ((~G8))|((~G7))|((~G6))|((~G131));
assign G67 = (G174)|(G175)|(G177);
assign G265 = (G317&G267);
assign G107 = (G41)|(G40)|(G1);
assign G71 = (G39)|(G281)|(G4)|(G67);
assign G267 = ((~G15));
assign G275 = ((~G285))|((~G286))|((~G287));
assign G90 = (G89&G88);
assign G279 = (G281&G42);
assign G215 = (G41&G42);
assign G262 = ((~G113))|((~G317));
assign G277 = (G323&G281&G280);
assign G281 = ((~G16));
assign G223 = (G16&G222);
assign G322 = ((~G41)&(~G38)&(~G323)&(~G324));
assign G202 = ((~G7));
assign G75 = ((~G207))|((~G208))|((~G206));
assign G292 = ((~G294)&(~G328)&(~G295));
assign G235 = (G317&G328);
assign G142 = (G40&G281);
assign G206 = ((~G230)&(~G231)&(~G232)&(~G233));
assign G288 = ((~G42)&(~G289));
assign G304 = ((~G328)&(~G313));
assign G101 = ((~G85))|((~G86))|((~G87))|((~G84));
assign G121 = (G318&G317&G328);
assign G261 = ((~G268)&(~G269));
assign G159 = ((~G164)&(~G165));
assign G149 = ((~G169)&(~G170));
assign G139 = (G317)|(G137);
assign G109 = (G201)|(G267)|(G328);
assign G255 = (G317)|(G253);
assign G321 = (G317)|(G318)|(G38)|(G319);
assign G237 = (G16)|(G39)|(G40);
assign G259 = (G41&G260);
assign G68 = ((~G185)&(~G186));
assign G311 = ((~G313))|((~G40))|((~G39))|((~G280));
assign G185 = (G280&G184);
assign G192 = ((~G199)&(~G200));
assign G125 = (G10)|(G12);
assign G195 = (G41&G42);
assign G181 = ((~G2));
assign G298 = ((~G42)&(~G313)&(~G40)&(~G299));
assign G204 = ((~G9))|((~G8));
assign G168 = ((~G12));
assign G229 = (G15)|(G313);
assign G296 = ((~G42)&(~G297));
assign G199 = (G245&G38&G41&G42);
assign G46 = ((~G318))|((~G280))|((~G16))|((~G122));
assign G318 = ((~G39));
assign G328 = ((~G42));
assign G59 = ((~G144))|((~G145));
assign G274 = ((~G282)&(~G283));
assign G179 = ((~G182))|((~G183));
assign G62 = (G267)|(G4)|(G57)|(G58);
assign G226 = (G318&G225);
assign G102 = (G101&G100);
assign G224 = ((~G238))|((~G239))|((~G240))|((~G241));
assign G317 = ((~G40));
assign G99 = (G98&G97);
assign G152 = (G313&G317&G318&G154);
assign G116 = (G39)|(G313);
assign G112 = ((~G8));
assign G64 = (G317)|(G318)|(G60);
assign G250 = (G39&G40&G42);
assign G86 = (G38)|(G82);
assign G287 = (G42)|(G5);
assign G241 = (G256)|(G317);
assign G306 = ((~G139))|((~G138));
assign G231 = (G267&G313);
assign G182 = (G14)|(G267)|(G38)|(G39);
assign G170 = (G171&G172);
assign G280 = ((~G38));
assign G214 = (G267&G16&G313);
assign G327 = ((~G328)&(~G329));
assign G76 = ((~G218)&(~G219)&(~G221));
assign G72 = (G317)|(G318)|(G68);
assign G133 = (G10)|(G172)|(G12)|(G42);
assign G266 = ((~G109))|((~G110))|((~G111))|((~G40));
assign G242 = (G41)|(G328);
assign G186 = ((~G191)&(~G192));
assign G203 = ((~G6));
assign G96 = (G95&G94);
assign G53 = ((~G42)&(~G54));
assign G249 = (G40&G41&G328);
assign G232 = (G38&G318);
assign G194 = (G10&G328);
assign G220 = ((~G223)&(~G224));
assign G278 = (G280&G42);
assign G143 = (G40&G4);
assign G305 = ((~G141)&(~G142)&(~G143));
assign G154 = ((~G276)&(~G277)&(~G278)&(~G279));
assign G106 = (G8)|(G7)|(G203)|(G105);
endmodule
