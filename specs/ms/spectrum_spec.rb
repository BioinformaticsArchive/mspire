
require File.expand_path( File.dirname(__FILE__) + '/../spec_helper' )
require 'ms/spectrum'

describe MS::Spectrum, 'equal_after_rounding?' do 
  before(:all) do
    @spectrum = MS::Spectrum.new
  end
  it 'returns equal after rounding' do
    [[123.32145, 123.32, true], [123.328, 123.32, false], [123, 124, false], [122.94532, 123, true], [123, 123, true], [6.233355, 6.2334, true], [1029.212890625, 1029.212891, true]].each do |ar|
      (precise, less_precise, answ) = ar
      @spectrum.equal_after_rounding?(precise.to_f, less_precise.to_f).should == answ
    end
  end


end
describe MS::Spectrum, 'with a few values' do
  before(:each) do
    @mz = [1.2, 4.23332, 5.345734, 6.233355, 7.889]
    @spec = MS::Spectrum.new(@mz,Array.new(5,100))
  end
  it 'finds an index given an exact m/z' do
    @mz.each_with_index do |x,i|
      @spec.index(x).should == i
    end
    [1, 4.233, 5.346, 6.2334, 7.89].each_with_index do |x,i|
      @spec.index(x).should == i
    end
  end

  it 'index returns nil if the m/z does not exist' do
    [0.9, 1.28, 0, -10, 100, 4.233322, 4.233310, 4.3, 8.001, 7.905].each_with_index do |x,i|
      @spec.index(x).should == nil
    end
  end
  it 'finds an index given a rounded m/z' do
    [1, 4, 5, 6, 8].each_with_index do |x,i|
      @spec.index(x).should == i
    end
  end

end

describe MS::Spectrum, 'of full values' do
  before(:each) do
    @spec = MS::Spectrum.new(Ref::MZ,Array.new(Ref::MZ.size,100))
  end

  it 'finds an index given an exact m/z' do
    @spec.index(1121.91625976562).should == 665
    @spec.index(1029.212890625).should == 597
    
    #@spec.index(1029.212891).should == 665
  end

  it 'finds an index given approximate m/z' do
    @spec.index(1121.91626).should == 665
    @spec.index(1029.212891).should == 597
  end

end






















class Ref
    MZ = [300.801086425781, 301.70166015625, 302.771240234375, 303.972473144531, 304.845275878906, 305.704711914062, 306.92919921875, 307.755126953125, 309.0087890625, 309.868713378906, 310.956420898438, 312.174194335938, 312.815185546875, 314.045654296875, 315.086730957031, 316.046752929688, 317.3525390625, 318.233642578125, 319.613647460938, 321.082092285156, 322.192321777344, 322.95458984375, 323.894653320312, 325.020385742188, 325.743286132812, 326.779418945312, 327.823303222656, 328.613891601562, 329.550903320312, 330.544738769531, 331.53125, 332.574829101562, 334.576965332031, 335.536254882812, 336.649353027344, 337.825805664062, 339.057189941406, 340.065063476562, 340.720581054688, 341.499572753906, 342.942199707031, 343.76025390625, 344.600280761719, 345.855041503906, 346.655639648438, 347.846435546875, 348.9169921875, 349.891235351562, 350.635437011719, 351.70458984375, 352.663940429688, 353.673217773438, 354.972717285156, 355.828247070312, 356.828125, 357.716613769531, 358.844848632812, 360.2294921875, 360.850402832031, 361.569580078125, 362.565002441406, 363.612182617188, 365.454711914062, 366.121337890625, 366.760559082031, 367.6083984375, 368.523986816406, 369.439453125, 370.830444335938, 371.803466796875, 372.514587402344, 374.044555664062, 374.806091308594, 375.821472167969, 377.040344238281, 377.854248046875, 378.756591796875, 379.71533203125, 380.576477050781, 381.725463867188, 382.475708007812, 383.616394042969, 384.813537597656, 386.129638671875, 387.6005859375, 388.932556152344, 390.297546386719, 391.094055175781, 392.089965820312, 392.823608398438, 394.235961914062, 394.960632324219, 395.694702148438, 396.635864257812, 397.776733398438, 399.250183105469, 400.538269042969, 401.433288574219, 402.387023925781, 402.995971679688, 403.692077636719, 404.801391601562, 405.716735839844, 406.731872558594, 408.219970703125, 409.398498535156, 410.421936035156, 411.209594726562, 412.011962890625, 412.739013671875, 413.435119628906, 414.143432617188, 415.083251953125, 416.492919921875, 417.629638671875, 418.542541503906, 419.22216796875, 419.897338867188, 420.7880859375, 421.839172363281, 422.86328125, 424.165710449219, 425.020263671875, 425.712097167969, 427.219360351562, 427.953247070312, 429.039367675781, 429.842346191406, 430.9833984375, 431.811462402344, 432.787719726562, 434.198486328125, 434.911071777344, 435.6279296875, 437.321166992188, 438.197448730469, 441.392822265625, 442.794372558594, 443.688232421875, 444.597534179688, 445.466247558594, 446.227966308594, 446.914245605469, 447.546936035156, 448.173278808594, 449.515563964844, 450.155517578125, 451.076049804688, 451.80859375, 452.888122558594, 454.161865234375, 455.119873046875, 456.791748046875, 457.733276367188, 458.702209472656, 459.986145019531, 460.669982910156, 461.494323730469, 462.233276367188, 463.476440429688, 464.808959960938, 465.488830566406, 466.521667480469, 467.236267089844, 468.25927734375, 469.573364257812, 470.788391113281, 471.397033691406, 472.3251953125, 473.016174316406, 473.884033203125, 474.768127441406, 475.71484375, 476.4599609375, 477.563171386719, 478.803833007812, 479.960021972656, 480.684143066406, 482.565612792969, 483.507568359375, 484.445495605469, 485.277221679688, 485.967590332031, 486.720397949219, 487.870178222656, 488.918029785156, 489.744018554688, 491.068664550781, 491.833435058594, 492.650573730469, 493.965026855469, 495.259765625, 496.394714355469, 497.059448242188, 498.060180664062, 499.154357910156, 501.302062988281, 502.07275390625, 504.229919433594, 505.106811523438, 505.800537109375, 508.017761230469, 508.681884765625, 509.696044921875, 510.333312988281, 512.247802734375, 513.393798828125, 514.066650390625, 515.622314453125, 516.840087890625, 518.3681640625, 519.65673828125, 521.18798828125, 521.8134765625, 522.556640625, 525.173583984375, 526.93017578125, 527.8955078125, 528.546630859375, 530.037109375, 530.682250976562, 531.6689453125, 533.123291015625, 534.359375, 535.144409179688, 535.915893554688, 537.208251953125, 537.831787109375, 538.450927734375, 539.700805664062, 540.919921875, 541.69873046875, 542.658203125, 544.65087890625, 546.431884765625, 547.52587890625, 549.49169921875, 551.28564453125, 552.2568359375, 554.173461914062, 554.998901367188, 555.777709960938, 556.683837890625, 557.781616210938, 558.829345703125, 559.62548828125, 561.412719726562, 566.22509765625, 568.303344726562, 569.317138671875, 570.64501953125, 571.35302734375, 572.68603515625, 573.504028320312, 574.764892578125, 576.551025390625, 578.062744140625, 579.164184570312, 579.979125976562, 580.649169921875, 581.505859375, 582.594116210938, 583.317016601562, 583.935546875, 584.800659179688, 585.533325195312, 586.652099609375, 588.186767578125, 589.5595703125, 591.04345703125, 593.177368164062, 594.206787109375, 595.06591796875, 595.67822265625, 596.616333007812, 598.947021484375, 599.933471679688, 601.442138671875, 602.24853515625, 603.02880859375, 604.325927734375, 605.169189453125, 606.299560546875, 608.28369140625, 609.507202148438, 610.47900390625, 611.820556640625, 616.285278320312, 617.404052734375, 618.650390625, 619.768432617188, 621.320068359375, 622.8955078125, 624.17431640625, 625.194091796875, 625.898803710938, 627.26611328125, 628.497802734375, 630.142333984375, 630.95556640625, 631.862182617188, 632.593872070312, 634.557373046875, 635.619506835938, 636.28173828125, 638.259521484375, 639.084716796875, 641.210693359375, 642.184326171875, 642.822143554688, 643.704345703125, 644.605224609375, 645.71630859375, 646.426391601562, 648.9580078125, 650.461791992188, 651.25927734375, 652.406005859375, 653.15771484375, 654.167236328125, 655.859619140625, 656.52783203125, 657.96044921875, 658.822143554688, 659.909545898438, 660.773681640625, 661.7734375, 664.002197265625, 664.96533203125, 666.625610351562, 668.973022460938, 669.7646484375, 670.6513671875, 672.27294921875, 673.169555664062, 674.858642578125, 675.718994140625, 676.745361328125, 677.466552734375, 678.604736328125, 680.147705078125, 681.142578125, 681.933349609375, 683.229736328125, 684.41357421875, 686.447509765625, 687.880859375, 689.662719726562, 690.491821289062, 691.112060546875, 694.089599609375, 694.885620117188, 695.734619140625, 698.015625, 699.21630859375, 700.71533203125, 702.184936523438, 703.388549804688, 704.596923828125, 705.3076171875, 706.487548828125, 707.610107421875, 708.528564453125, 709.323608398438, 710.18505859375, 711.12939453125, 712.266967773438, 713.28564453125, 715.2998046875, 716.581298828125, 717.333251953125, 718.65185546875, 719.658813476562, 721.110717773438, 722.131591796875, 723.205322265625, 724.197265625, 725.251342773438, 726.477783203125, 727.608154296875, 728.540283203125, 729.320678710938, 730.3056640625, 731.65185546875, 733.397705078125, 734.366943359375, 735.504150390625, 736.795166015625, 738.273315429688, 740.48046875, 741.299072265625, 742.173461914062, 742.86669921875, 744.785888671875, 746.8779296875, 748.128784179688, 748.85986328125, 750.027709960938, 750.9765625, 751.95361328125, 753.22216796875, 754.343505859375, 755.197631835938, 756.30712890625, 756.968139648438, 757.953491210938, 759.24609375, 760.630615234375, 762.342041015625, 763.35302734375, 765.677978515625, 766.75634765625, 768.7939453125, 769.42138671875, 770.463500976562, 771.560180664062, 772.955078125, 775.075927734375, 775.7666015625, 776.741333007812, 777.477416992188, 779.6455078125, 780.4052734375, 781.199340820312, 782.47265625, 783.567260742188, 784.414794921875, 785.167358398438, 785.986083984375, 787.664794921875, 788.28759765625, 791.491821289062, 793.939086914062, 795.66455078125, 797.485595703125, 798.37841796875, 799.091796875, 800.07421875, 801.76806640625, 802.5009765625, 803.33642578125, 806.570556640625, 807.333251953125, 808.1796875, 809.757690429688, 810.576171875, 811.278564453125, 813.463623046875, 814.234252929688, 815.956665039062, 818.929931640625, 820.739624023438, 822.134033203125, 823.384643554688, 824.442260742188, 827.7109375, 829.531616210938, 830.426879882812, 832.463134765625, 833.255004882812, 834.453125, 835.244750976562, 836.306396484375, 837.582153320312, 838.958251953125, 840.4677734375, 841.878173828125, 843.275024414062, 844.0, 845.133544921875, 846.884399414062, 847.799926757812, 848.9990234375, 850.070434570312, 851.87646484375, 854.469604492188, 855.295166015625, 857.824829101562, 860.77685546875, 862.132202148438, 863.554321289062, 864.557250976562, 865.8017578125, 867.702270507812, 868.665649414062, 869.851806640625, 872.493774414062, 873.479125976562, 875.295043945312, 876.073608398438, 877.45458984375, 878.231567382812, 879.895141601562, 881.426513671875, 882.178955078125, 882.82421875, 884.2978515625, 885.93603515625, 887.682739257812, 888.5888671875, 889.888305664062, 891.596313476562, 892.661010742188, 893.334716796875, 894.553466796875, 897.082275390625, 899.702270507812, 901.876586914062, 903.037475585938, 904.111450195312, 906.00146484375, 906.629516601562, 908.138671875, 909.345825195312, 911.360107421875, 913.2080078125, 915.34326171875, 915.966552734375, 918.234741210938, 919.238403320312, 920.685913085938, 922.227783203125, 925.145385742188, 926.242797851562, 927.669921875, 928.302124023438, 929.865600585938, 931.137939453125, 931.89404296875, 932.522705078125, 933.502563476562, 934.323364257812, 936.171630859375, 936.822021484375, 938.020751953125, 940.005615234375, 941.223266601562, 942.777587890625, 943.456787109375, 945.176391601562, 946.310302734375, 947.45068359375, 950.406494140625, 951.199829101562, 952.004028320312, 952.9482421875, 954.328369140625, 955.021484375, 955.98681640625, 957.270385742188, 958.439697265625, 959.066650390625, 961.471313476562, 964.653442382812, 965.29296875, 966.430786132812, 967.450073242188, 969.279663085938, 970.070434570312, 972.778686523438, 975.616088867188, 976.281982421875, 977.298461914062, 980.384887695312, 982.016845703125, 983.19482421875, 985.753173828125, 986.75439453125, 987.38916015625, 988.11328125, 989.251220703125, 991.101318359375, 992.167358398438, 993.356567382812, 994.288818359375, 994.909545898438, 996.360107421875, 997.033203125, 999.596435546875, 1000.70825195312, 1001.82934570312, 1002.5859375, 1003.97521972656, 1006.16870117188, 1007.17919921875, 1008.37512207031, 1010.92126464844, 1011.68957519531, 1014.60095214844, 1015.32788085938, 1016.53491210938, 1019.423828125, 1021.97961425781, 1023.03479003906, 1024.06762695312, 1025.23022460938, 1028.0390625, 1029.212890625, 1030.20458984375, 1030.9814453125, 1031.58642578125, 1032.22314453125, 1033.47900390625, 1035.31103515625, 1036.27783203125, 1037.73461914062, 1040.73681640625, 1041.61083984375, 1042.40795898438, 1044.15625, 1047.22192382812, 1048.4150390625, 1049.326171875, 1050.52856445312, 1052.19677734375, 1052.86840820312, 1055.55029296875, 1056.19995117188, 1056.91650390625, 1059.255859375, 1060.0, 1060.95922851562, 1062.39501953125, 1063.42504882812, 1064.02978515625, 1066.18505859375, 1067.46337890625, 1068.771484375, 1070.34008789062, 1071.54541015625, 1072.4619140625, 1073.06665039062, 1074.25317382812, 1075.02587890625, 1075.91650390625, 1077.90380859375, 1078.623046875, 1079.625, 1081.20092773438, 1082.90673828125, 1084.12646484375, 1084.93627929688, 1086.10693359375, 1086.8212890625, 1089.87060546875, 1090.95751953125, 1091.58227539062, 1092.58056640625, 1093.18798828125, 1094.03076171875, 1094.85888671875, 1095.67578125, 1096.91772460938, 1097.76611328125, 1099.94018554688, 1104.1787109375, 1106.17016601562, 1109.21435546875, 1110.64526367188, 1111.39990234375, 1115.15551757812, 1118.62060546875, 1119.3232421875, 1120.49560546875, 1121.24438476562, 1121.91625976562, 1123.04467773438, 1124.11328125, 1125.00732421875, 1128.94750976562, 1132.93701171875, 1135.576171875, 1137.48706054688, 1140.6787109375, 1142.33544921875, 1144.44482421875, 1145.72021484375, 1146.33325195312, 1148.22900390625, 1151.29833984375, 1155.04272460938, 1155.8359375, 1157.00634765625, 1159.06323242188, 1160.17724609375, 1161.82397460938, 1164.59252929688, 1166.2470703125, 1169.43603515625, 1172.52734375, 1174.78784179688, 1175.90966796875, 1177.07763671875, 1178.1201171875, 1179.05493164062, 1180.10815429688, 1181.087890625, 1182.23583984375, 1183.14404296875, 1183.8203125, 1184.86596679688, 1185.9677734375, 1187.96240234375, 1192.14208984375, 1192.8876953125, 1194.31494140625, 1195.25439453125, 1197.404296875, 1198.44677734375, 1199.986328125, 1200.9560546875, 1202.10986328125, 1204.16528320312, 1204.92626953125, 1207.64697265625, 1209.29638671875, 1210.31469726562, 1211.55810546875, 1212.96728515625, 1213.66650390625, 1215.88720703125, 1216.65844726562, 1221.25219726562, 1222.03955078125, 1222.94189453125, 1223.84765625, 1224.94677734375, 1226.40893554688, 1227.57470703125, 1229.04736328125, 1229.91796875, 1233.10815429688, 1234.28564453125, 1235.01904296875, 1236.62036132812, 1238.3466796875, 1242.61328125, 1247.39184570312, 1248.78662109375, 1250.59375, 1253.32861328125, 1254.3173828125, 1256.03540039062, 1259.39404296875, 1261.6796875, 1263.22534179688, 1265.2001953125, 1267.65600585938, 1271.38818359375, 1272.033203125, 1272.81103515625, 1273.9462890625, 1275.4443359375, 1276.86669921875, 1277.63012695312, 1278.470703125, 1283.57397460938, 1285.2294921875, 1286.77807617188, 1287.529296875, 1289.22631835938, 1289.90405273438, 1290.55541992188, 1291.89868164062, 1293.01733398438, 1297.19946289062, 1298.38549804688, 1299.29638671875, 1300.2783203125, 1303.30151367188, 1304.17211914062, 1306.76318359375, 1307.55786132812, 1308.35620117188, 1310.16162109375, 1312.1787109375, 1313.92797851562, 1314.58325195312, 1315.9853515625, 1318.7001953125, 1320.08544921875, 1321.87451171875, 1322.6083984375, 1323.46728515625, 1324.13891601562, 1326.99365234375, 1329.58764648438, 1334.52392578125, 1335.72412109375, 1336.44018554688, 1340.24731445312, 1342.57275390625, 1345.16650390625, 1346.63305664062, 1348.08911132812, 1352.998046875, 1354.26928710938, 1354.98779296875, 1355.89990234375, 1360.693359375, 1361.45068359375, 1370.07788085938, 1373.84790039062, 1376.78540039062, 1378.5107421875, 1379.88793945312, 1382.77880859375, 1386.8427734375, 1389.30444335938, 1391.45263671875, 1392.22045898438, 1395.37744140625, 1396.14916992188, 1401.87231445312, 1408.41772460938, 1409.84790039062, 1411.30883789062, 1414.53955078125, 1415.2880859375, 1417.7275390625, 1418.34155273438, 1419.27978515625, 1420.90063476562, 1422.11083984375, 1423.06079101562, 1423.76318359375, 1424.69409179688, 1425.6943359375, 1426.994140625, 1438.1064453125, 1441.8935546875, 1445.77099609375, 1448.7431640625, 1455.90747070312, 1458.3203125, 1462.12548828125, 1463.53540039062, 1466.44091796875, 1469.74291992188, 1472.12841796875, 1473.33764648438, 1478.65185546875, 1479.49877929688, 1480.69287109375, 1487.7763671875, 1493.84423828125, 1497.70141601562] 
end
