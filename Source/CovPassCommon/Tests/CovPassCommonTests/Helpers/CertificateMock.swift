//
//  CertificateMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct CertificateMock {
    
    //    {
    //        "1" : "DE",
    //        "4" : 1651936419,
    //        "6" : 1620400419,
    //        "-260" : {
    //            "1" : {
    //                "v" : [ {
    //                    "ci" : "01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S",
    //                    "co" : "DE",
    //                    "dn" : 2,
    //                    "dt" : "2021-02-28",
    //                    "is" : "Bundesministerium für Gesundheit (Test01)",
    //                    "ma" : "ORG-100030215",
    //                    "mp" : "EU/1/20/1528",
    //                    "sd" : 2,
    //                    "tg" : "840539006",
    //                    "vp" : "1119349007"
    //                } ],
    //                "dob" : "1997-01-06",
    //                "nam" : {
    //                    "fn" : "Ionut",
    //                    "gn" : "Balai",
    //                    "fnt" : "IONUT",
    //                    "gnt" : "BALAI"
    //                },
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertificate = "HC1:6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDE$VK G2EP4J0B3KL6QM5/OVGA/MAT%ISA3/-2E%5VR5VVBJZILDBZ8D%JTQOLC8CZ8DVCK/8D:8DQVDLED0AC-BU6SS-.DUBDNU347D8MS$ESFHDO8TF724QSHA2YR3JZIM-1U96UX4795L*KDYPWGO+9A*DOPCRFE4IWM:J8QHL9/5.+M1:6G16PCNQ+MLTMU0BR3UR:J.X0A%QXBKQ+8E/C5LG/69+FEKHG4.C/.DV2MGDIE-5QHCYQCJB4IE9WT0K3M9UVZSVK78Y9J8.P++9-G9+E93ZM$96TV6KJ73T59YLQM14+OP$I/XK$M8AO96YBDAKZ%P WUQRELS4J1T7OFKCT6:I /K/*KRZ43R4+*431TVZK WVR*GNS42J0+-9*+7E3KF%CD 810H% 0NY0H$1AVL9%7L26Y1NZ1WNZBPCG*7L%5G.%M/4GNIRDBE6J7DFUPSKX.MLEF8/72SEPKD++I*5FMHD*ZBJDBFKEG2GXTL6%7K7GK7QQ1C3H0A/LGIH"
    //    {
    //        "1" : "DE",
    //        "6" : 1644598785,
    //        "4" : 1676134785,
    //        "-260" : {
    //            "1" : {
    //                "nam" : {
    //                    "gn" : "Erika Maria",
    //                    "fn" : "Mustermann",
    //                    "gnt" : "ERIKA MARIA",
    //                    "fnt" : "MUSTERMANN"
    //                },
    //                "dob" : "1964-08-13",
    //                "v" : [ {
    //                    "ci" : "01DE/84503/1644598785/DXSGWLWL40SU8ZFKIYIBK30A4#S",
    //                    "co" : "DE",
    //                    "dn" : 2,
    //                    "dt" : "2021-08-01",
    //                    "is" : "Bundesministerium für Gesundheit",
    //                    "ma" : "ORG-100001699",
    //                    "mp" : "EU/1/21/1529",
    //                    "sd" : 2,
    //                    "tg" : "840539006",
    //                    "vp" : "1119349007"
    //                } ],
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertificate2 = "HC1:6BFOXN%TSMAHN-HWWK2RL99TEZP3Z9M52%EL1WG%MPG*I:G5UZD9M4BXAUZUL+H:ZH6I1$4J/9TL4T.B95CQD.EVSPR+92HU T52T9MK9AZP0W5E%5MZ5Q$9NVPF/94O5Q-E6WU7/E.HUTS1RVEB/94O50RUCT16DEETUM/UIN9AKPCPP7ZMZO6JZ6LEQPR6VR5VVBJZILDBZ8D%JTQOL0EC7KD/ZL-8DVJCGKDCECRFC2AU/B2/+3HN2HPCT12IID*2T$/TVPTM*SHYDBADYR3JZI-.1TDCTG90OARH9P1J4HG8C4-Q8:WOP+PJD1W9L $N3-Q4-R9 N8DI5G6VOE:OQPAU:IAJ0AZZ0OWCR/C+T4D-4HRVUMNMD3*20EJK-+K.IA.C8KRDL4O54O6KKUJK6HI0JAXD15IAXMFU*GSHGRKMXGG6DBYCB-1JMJKR.KI91L4DWVBDKBYLDN4DE1DWKSN*U:N5-VVSMJM16PKA0+7H6W%GHH8T93F7Q7ORGI%3ZML.PA.N6N8N5VQ8+ELRJ/YOR4WWU95:6HJJ7CLLMFE4QSK386RXG1:PE$RL*10WC8W3"
    
    //    {
    //        "1" : "DE",
    //        "6" : 1646152281,
    //        "4" : 1677688281,
    //        "-260" : {
    //            "1" : {
    //                "nam" : {
    //                    "gn" : "Max",
    //                    "fn" : "Mustermann",
    //                    "gnt" : "MAX",
    //                    "fnt" : "MUSTERMANN"
    //                },
    //                "dob" : "1964-08-12",
    //                "v" : [ {
    //                    "ci" : "URN:UVCI:01DE/84503/1646152281/DXSGWLWL40SU8ZFKIYIBK30A4#S",
    //                    "co" : "DE",
    //                    "dn" : 2,
    //                    "dt" : "2022-02-01",
    //                    "is" : "Robert Koch-Institut",
    //                    "ma" : "ORG-100031184",
    //                    "mp" : "EU/1/20/1507",
    //                    "sd" : 2,
    //                    "tg" : "840539006",
    //                    "vp" : "1119349007"
    //                } ],
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertificate3 = "HC1:6BF280090T9WTWGSLKC 4979Y.QU UQ3L+1JFBBJR2*70HS8WY08IC/H9FN0*SC.+FD97TK0F90TPCBEC7ZKI3D-OCMECZJC6/DTZ9 QE5$CB$DA/DMPCG/D-OCXB8LPCG/DXJDIZAITA9IANB8.+9GVC*JC1A6G%63W5Q47*96KECTHGWJC0FD%G7AIA%G7X+AQB9746HS8S/50R6946L/5G%6D%6SW6VF6 96 S8YNAS1BS1B+Q63OAQ57+*8CC9YB9 M9N46RQ6GOAUPC1JCWY8FVCPD0LVC6JD846KF68463W5.A6+EDXVET3E5$CSUE6O9NPCSW5F/DBWENWE4WEB$D% D3IA4W5646946%96X47.JCP9EJY8L/5M/5546.96D463KC.SC4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646407O/EZKEZ96446156/48RV6HFCEEO1/DQTP3XOD0CP+AINIM5N6L02RH1+EY$JD2B*/FY*EMXT0NC787/$JMUBLG75-VLYF0RP19JKLTN.5N-LB*VR6T70HY2"
    
    
    //    {
    //        "1" : "DE",
    //        "6" : 1645804863,
    //        "4" : 1677340863,
    //        "-260" : {
    //            "1" : {
    //                "nam" : {
    //                    "gn" : "Biontech",
    //                    "fn" : "Pfizer21",
    //                    "gnt" : "BIONTECH",
    //                    "fnt" : "PFIZER21"
    //                },
    //                "dob" : "2000-11-11",
    //                "v" : [ {
    //                    "ci" : "01DE/84503/1645808463/DXSGWLWL40SU8ZFKIYIBK30A4#S",
    //                    "co" : "DE",
    //                    "dn" : 2,
    //                    "dt" : "2022-02-01",
    //                    "is" : "Bundesministerium für Gesundheit",
    //                    "ma" : "ORG-100030215",
    //                    "mp" : "EU/1/20/1528",
    //                    "sd" : 2,
    //                    "tg" : "840539006",
    //                    "vp" : "1119349007"
    //                } ],
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertificate4 = "HC1:6BFOXN%TSMAHN-HISCCPV4DU30PMXK/R89PPNDC2LE%$CAJ9AIVG8QB/I:VPI7ONO4*J8/Y4IGF5JNBPINXUQXJ $U H9IRIBPI$RU2G0BI6QJAWVH/UI2YU-H6/V7Y0W*VBCZ79XQLWJM27F75R540T9S/FP1JXGGXHGTGK%12N:IN1MPK9PYL+Q6JWE 0R746QW6T3R/Q6ZC6:66746+O615F631$02VB1%96$01W.M.NEQ7VU+U-RUV*6SR6H 1PK9//0OK5UX4795Y%KBAD5II+:LQ12J%44$2%35Y.IE.KD+2H0D3ZCU7JI$2K3JQH5-Y3$PA$HSCHBI I799.Q5*PP:+P*.1D9R+Q0$*OWGOKEQEC5L64HX6IAS3DS2980IQODPUHLO$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L6G%5TW5A 6YO67N6N7E931U9N%QLXVT*VHHP7VRDSIEAP5M9N0SB9BODZV0JEY9KQ7KEWP.T2E:7*CAC:C5Z873UF C+9OB.5TDU1PT %F6NATW6513TMG.:A+5AOPG"
    //    {
    //        "1" : "DE",
    //        "6" : 1646072738,
    //        "4" : 1654712738,
    //        "-260" : {
    //            "1" : {
    //                "dob" : "1950-08-12",
    //                "nam" : {
    //                    "fn" : "Mustermann",
    //                    "fnt" : "MUSTERMANN",
    //                    "gn" : "Erika",
    //                    "gnt" : "ERIKA"
    //                },
    //                "v" : [ {
    //                    "ci" : "01DE/84503/1645116305/DXSGWLWL40SU8ZFKIYIBK30A4#S",
    //                    "co" : "DE",
    //                    "dn" : 1,
    //                    "dt" : "2021-11-25",
    //                    "is" : "Bundesministerium für Gesundheit",
    //                    "ma" : "ORG-100001699",
    //                    "mp" : "EU/1/21/1529",
    //                    "sd" : 1,
    //                    "tg" : "840539006",
    //                    "vp" : "1119305005"
    //                } ],
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertificate5 = "HC1:6BF2Y2%-NLVO/23WECB.ODO0UA8Q316DKN%K44SK85H87LTQJ4R33GNUHLX5FPI6+OJPAQ MFV2.8E4XJL JXQ2TMGL47YDL-/UHQ2R7AYHQYMP9M1 NFTTM54I:FJYK6.7916KL28E8P-ZV2HF7BO88CUCDFKCJ0AH52AXOSPJTYMGB69:R6X85WCYCMHKC*BR78TGIM/:T+OR$$9*JQ:-Q5+QIL6V$EXKPDQKEWQU KVRS2N5I/BT4OXUCBOTA-A15EU.DDFGHXBBQ4/Q4IZ1XJGA12EL2 QH7PLH+GO$GRHGRB74DDT.JA7LQLTREH4M80UTLV59G35E8Y8NWNO%L1LRU4JBU E..AM2HY97F0N7A52KRW35KAM GGOOTG5P*HD6HTR3QM-6WD0$S0*CB 4D2%KP87TCF7980+CIN1+2WVU45R8ZWPYU8+OM-J0X%RL72UQTOVQB94VH8KIEAKLSOR .OC4US1MV1ABMRG:N2EFOTAIMPU3Q*%NRTHW1QL6D3*3*QEFAQAL7002$MT$OBV$VP/R9XR*UFSCS3DR*JPHO7HQG"
    //    {
    //      "1" : "DE",
    //      "6" : 1645804816,
    //      "4" : 1677340816,
    //      "-260" : {
    //        "1" : {
    //          "nam" : {
    //            "gn" : "Biontech",
    //            "fn" : "Pfizer21",
    //            "gnt" : "BIONTECH",
    //            "fnt" : "PFIZER21"
    //          },
    //          "dob" : "2000-11-11",
    //          "v" : [ {
    //            "ci" : "01DE/84503/1645808416/DXSGWLWL40SU8ZFKIYIBK30A4#S",
    //            "co" : "DE",
    //            "dn" : 1,
    //            "dt" : "2022-02-01",
    //            "is" : "Bundesministerium für Gesundheit",
    //            "ma" : "ORG-100030215",
    //            "mp" : "EU/1/20/1528",
    //            "sd" : 1,
    //            "tg" : "840539006",
    //            "vp" : "1119349007"
    //          } ],
    //          "ver" : "1.0.0"
    //        }
    //      }
    //    }
    static let validCertificate6 = "HC1:6BFOXN%TSMAHN-HISCCPV4DU30PMXK/R89PPNDC2LE%$CAJ9 GV1DOB/I:VPHKGNO4*J8/Y4IGF5JNBPINXUQXJ $U H9IRIBPI$RU2G0BI6QJAWVH/UI2YU-H6/V7Y0W*VBCZ79XQLWJM27F75R540T9S/FP1JXGGXHGTGK%12N:IN1MPK9PYL+Q6JWE 0R746QW6T3R/Q6ZC6:66746NU615F631$02VB1%96$01W.M.NEQ7VU+U-RUV*6SR6H 1PK9//0OK5UX4U96Y%KBAD5II+:LQ12J%44$2%35Y.IE.KD+2H0D3ZCU7JI$2K3JQH5-Y3$PA$HSCHBI I799.Q5*PP:+P*.1D9R+Q0$*OWGOKEQEC5L64HX6IAS3DS2980IQODPUHLW$GAHLW 70SO:GOLIROGO3T59YLLYP-HQLTQ9R0+L6G%5TW5A 6YO67N6OAEESI R5DXAQ3OYHT52N:THB1R+%9:QEHJ6TO5E4F4YUYOTF:19YP47J5-9Q9BT5DQYO3 FX Q :LU-KYXM6AV$RH9-N+NPXMQKSR58RXDJNOG"
    
    static let validCertificateNoPrefix = CertificateMock.validCertificate.stripPrefix()
    static let invalidCertificate = "6BF:XVTAOMEVT-VXI24H9STEWXMQRA6J668060BT4"
    static let invalidCertificateOldFormat = "6BFWZ8VIMDWR-53HT0+M981HE-IQ%8/MLK3OK$JZXDCGE+014R2NJADEJXDTJ7VLGVX0SB 9312D7155F2G70VAIFT4ILV:Q++L6%2NNKAA9-K56EOG:6ASTGBSDAOY4FI/AXBJ PN%%Q LUGEVRDDH4A*5KE6O15OO8LPMNC29JDFGZH/QAHKQ2LTXXSDMPJH4LPLK.PYYRZPR-J3PRBI*HO.NGDRI*EMJCT-J:2D8WAYHOM84G$7S67S44Z64WD3J34HRIZ60U9BHN2:GG$33GJAY7CN%K22BVZGI30/73X6613TK-A4W4HB8W$2 DOHTAZ$PJI8K 12620OL-98V.6TNADD54T8RKK.FISK6/69HGT698+VG0IEIK7CBKPICPHK5.8U27VG1S6B*HDM:A%IGWTC/-T$VE62H19OVT9ND4H7E6JKBOU9ED9.3PDKV$AFGW-AV3OOE6K$$IE525I00IAEQ06P3LFGL9C*IHT*K9XB7*F+TQD9UCGVFVTU9KT1P3COHK7-8TR%T$4WS6RDDWYC7:TDHDTI8T8X20ZST9W6.VQE9Y0GPDL6-37+8N+0Q1LLZBCA9OC0O7820"
    static let invalidCertificateInvalidSignature = "HC1:6BFOXN:F2W.M.DA/V4$-O4NP3I4BIRIAB%+QGR6LCRESOH99SOO1W4K27A876HP7R710PH$QZDDJS48:U92PZ.2/+69S8Z+CA 2 GD/GPWBI$C9.-B97UI%K6ZNWBRZ+P/Q8G8J.XR H9.UIZTU$MGUM6 L6JG94WFJRHQJA/IEZ$UCPI2YUQKEQQG%+N6$DU+VWQGTVBXZQ2J92NGZY7NX7*H8-VFXQGDVB3VF+4WJMI:TU+MMPZ5.T9.T19UEO$HJUPY0BZW4Z*AKD3ARNAST4DJKD3MWTMD3QHBXSJKD3.EJFUN-Q0Q8HN GBAJYP0NIB6KNDQFFKF/DF:NB*D3V+0SZ4:L0YZJ0PIBZIXJA  CG8C5DLA6CLS8ZJJOW2I.9CEF KL%KNYGFO74-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMFRMLNKLK4JI0JPG$:0TXTE L::RTQP:UTEZ1-GC%XO4COUDUW*B BCK27$IUB2IKNM6RQFQ3X7SVOV NP%EW+JJ0G2PTSHBO5EBD:UNXJG RH*D/MS2Y6RZEL.93LI"
    //    {
    //        "1" : "IS",
    //        "4" : 1624613812,
    //        "6" : 1622021812,
    //        "-260" : {
    //            "1" : {
    //                "v" : [ {
    //                    "ci" : "URN:UVCI:01:IS:VERA1234#F",
    //                    "co" : "IS",
    //                    "dn" : 2,
    //                    "dt" : "2021-01-01",
    //                    "is" : "Directorate of Health of Iceland Test",
    //                    "ma" : "ORG-100030215",
    //                    "mp" : "EU/1/20/1528",
    //                    "sd" : 2,
    //                    "tg" : "840539006",
    //                    "vp" : "J07BX03"
    //                } ],
    //                "dob" : "2000-01-01",
    //                "nam" : {
    //                    "fn" : "Prófarason",
    //                    "gn" : "Þarf Að Prófa",
    //                    "fnt" : "PROFARASON",
    //                    "gnt" : "THARF<AD<PROFA"
    //                },
    //                "ver" : "1.0.0"
    //            }
    //        }
    //    }
    static let validCertifcateRSA = "HC1:NCFOXNYTSFDHJI8M-OS6LV5UIXJAVI7LGI/8RX4 D9.IOVGAK0BS3E-RIM6BY4N NI4EFSYS:%OD3PYE9*FJ7OIQC8$.AIGCY0K5$0Y.A*JOVFC.C8*/GB2PRQPYE9/MVZ*J.A5:S9395*CBVZ0K1H%Y0BZIGDB5LKPMIHZISVBX3C*8BEPLA8KOHSLOJJPA*709EF7AL-T4P*KQYGN%2+T4D-4HRVUMNMD3323R13A2VC-4A+2XEN QT QTHC31M3+E3CP456L X4CZKHKB-43.E3KD3OAJ5%IWZKRA38M7323Q05.$S580QW6:CGPOJI7JSTNB95V/5HFKKKUG%M/PKDVS7%NC.U+NG WUJUHIO2 .1/7AI596AL**IOS0VPVI97I97M%V9Y4KCT1+S-8FB%0XKR.RNPCGZUIQJAZGA2:UG%U:D4LC3G5U48S8BQAQI.DCDIU%PARZH3874N462D:PUO21VFFYKJ92T2O5WMHU+GDZMQAU.QVF5FJFK$VTA4SBPN%OENJ6Y.6S:4HTNV.K-RNP/U+$S1KKXD5L.RD6N72TX1G7VL2-3:GD-C8+THI RE+2BLBTEU%R96LBHGT-9TRGEDFNF/SO3D1ATL8E: 3RIR:2VPVB+*FL3VS5II5SSCMA4FYEV1ZOGK1W3E*8R3GADTR5N2DV75KR30VK%F0 U%K14J27RMF3NYCWHX70GQ*E823HO0JJPESSR9HVC%P:J4$/K5HC9SUNTH TKB3W7YUCTGV/J/6JV9K8WM0U9MGM5UNPP6$0OLPB7BOO%V-.MEH63WP.NHQ9SI/JFJ7R87HTGZWE70V/3O4+I.7LF:1000C+NZLS"
    static let validExtendedKeyUsageGreece = "HC1:NCFOXNEG2NBJ5*H:QO-.OMBN+XQ99N*6RFS5$JVTWG4G5I.PKT1WJLMER:GGQF95D8:ZH6I1$4JV7J$%25I3HC3183/9TL4T.B9GYPMA71ETMQJC.H :EVXR 1OCA7G6M01Q9D6YVQM473X7A-160NT%R:64J4FZW5 F6G6M5YOF1R2/Q:ER%47+V4YC5/HQ*$QXCR*888EQYKMXEE5IAXMFU*GSHGRKMXGG6DBYCBMQN:HG5PAHGG.IA.C8KRDL4O54O4IGUJKJGI.IAHLCV5GJM77UK HG4HGBIK6IA*$30JAXD16IASD9M82*882EOPCR:36/973KTN$KKQS7DS2*N.SSBNKA.G.P6A8IM%OVNI2%KYZP6NP.MKLWLVRMES9PI05P5034LOE7/5*OCV.29%CN31:T0.QMF3L1+DKAM$.UH9QB T0TIBMRZB19FWX6GLXHRMQ%NKA3WSJJDQS:/K43W-/VN+FB%602UCWJCZVK/SO901A6/7WAWPO1OB8R8502*FR5"
    static let invalidExtendedKeyUsagePoland = "HC1:6BFC80Z80T9WTWGVLK659A:TG4G$BTZM0X*4FBBE*3FN0KKC+H3WY0/9CWC4*70 6AD97TK0F90KECTHGXJC$+D.JCBECB1A-:8$966469L6OF6VX6Z/ER2DD46JH8946XJCCWENF6OF63W5NW60A6WJCT3E 6AWJC0FDTA6AIA%G7X+AQB9746XG7TS9 967:6DL6WX8BM8CA6DB83R63X6$A7UF6QG8Q46/A8.A8$96V47.JCP9EJY8L/5M/5 96.96WF6%JCXQEIN8G/D6LE ZDQZCAJB0LEE4F0ECKQEPD09WEQDD+Q6TW6FA7C46TPCBEC8ZKW.CHWEBIAG09:S9Q+9DN90S7BIAOT9W.CUEEY3EAECWGDMXG2QDUW5*MEWUMMPCG/D8EDETAG+9*NAWB8 JC6/DYOACEC+EDR/OLEC$PC5$CUZCY$5Y$5JPCT3E5JDKA7Q47%964W5WA6N68$E5FAWIBG9SQCLEH19FZMD8B TL6AW8JJRBHTB91L0GMSNRCBBPL8R958CR2:7T84H7*6C V86W0*8G1MZJVS72L:M5WAB9UB0HF0"
    static let validRecoveryCertificate = "HC1:6BFOXN*TS0BI$ZDFRH5+FPWF9EIZ.0SAH9M9ESIGUBA K//AZAS-RI*87DK2-MPW$NLEEEJCY S2%KYZP-3WK34JWLG56H0API0Z.2W+F245EL4.J2V192SIGPE:/8.9PSBL1UPCQI4AQG0B%14911/0T2%K:XF:EFQA5*CBVZ0K1HO%0CNNZ 2-B5S8ANX4.5J6YG+L66PP+ 5-PP:G9XF5-JU04AXIQM P7-5AQ5SW5PF5RBQ746B46O1N646IN9AKPCPP0%M.P6-SJE2KI7JSTNB95P/5+P4$17M473X7E.P216X35IL6+Y5:P4U*O99R%47-Z7GT4QNQ.Y4*.QJINQ+MN/Q19QE8QTSOZ2G3SIZ2S5ANOVPN-G%5FU:NDNS $AJ6DE3E%CVL4CG5FAZ8Y7SG/V1H8WO5V6S/I2G/ETIRPCRT$P+ZT+IN$NR7$QJ$U$ TQFQVMBJFTGGE"
}
