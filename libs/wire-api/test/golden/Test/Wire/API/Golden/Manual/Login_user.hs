-- This file is part of the Wire Server implementation.
--
-- Copyright (C) 2022 Wire Swiss GmbH <opensource@wire.com>
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU Affero General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
-- details.
--
-- You should have received a copy of the GNU Affero General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.

module Test.Wire.API.Golden.Manual.Login_user where

import Data.Code
import Data.Handle (parseHandle)
import Data.Maybe
import Data.Misc (plainTextPassword6Unsafe)
import Data.Range (unsafeRange)
import Data.Text.Ascii (AsciiChars (validate))
import Imports
import Wire.API.User (Email (Email, emailDomain, emailLocal))
import Wire.API.User.Auth

testObject_Login_user_1 :: Login
testObject_Login_user_1 =
  MkLogin
    (LoginByEmail (Email {emailLocal = "4\1069339\vEaP", emailDomain = "\ENQ\n\FS\ESC\997356i03!"}))
    ( plainTextPassword6Unsafe
        "\b5Ta\61971\150647\186716fa&\1047748o!ov\SI\1100133i\DC4\ETXY\SOR\991323\1086159Ta^s\ETB\SI[\189068\988899\26508\CAN6\STXp\1069462-9\983823&\NAK\1052068]^\13044;>-Z$Z\NAK\r\1101550a\RS%\NUL:\188721\47674\157548?e]\ETX \142608 C\SOH\SIS%8m\1091987V\147131[\1006262\&6\171610\1011219\164656SX\n%\1061259*>\t+\132427Y\989558\993346\GSU\1067541\&6TU!*\40114\&90\1055516\RSV\162483N\t*\EOT{I<\1084278\SOH\183116!c\\\n\1107501\183146\DC1,-xX\EMV?\t\168648\1054239\DC2\DEL1\SOHu\SOH\63459\53061\SO+h\ACK::\RS\21356_g,\SO*\v\DC4\1093710HFF\188918\1081075fF\ESC2\SOHT\DC1)\fc\35905l\1061547\f#~\STX]\1035086/Or)kY\1031423\SOHNCk\1067954\&5\1083470x=H\NUL\23760\1058646\1099097E/$\DELpbi\137522\FSKi\15676\1018134\t7\"OL\54208\7516\&5\43466\NUL(\1030852\166514\SOH\149343\994835\25513C==\GSTV3\DELl6\999006.Z)$\16723|\172732\1090303J;O\GSbw\vI\1101024I\SYN\DC2^\149630\STX3%i\EMW\138614\DC4\1113619tsL5\147087W\96700(_,\1091179*\1041287rckx\SOH\SIs\SOHJd\140574\SYNev.\DC4\DLE\99082.\1106785\996992\143448\US_\ETBf\STX\SO\DC3\1043748\&6O\DC1Q\SOH'\GS,|]W\SIa\62568\151062.\v\aH&-L\DC2+\147179\1095524\EOTm)\19925\181147\183368!\185223\142946m\DC4\DC3\1034282m\GS\185509>>\"NDw\1076877hY\1033831sFKz^ \1108187\&5Qec\NAK}|\1108194.Q\173114imb\1027220 p;\1089082\SYN\1065748kF\1102854r8o\DC1"
    )
    (Just (CookieLabel {cookieLabelText = "r"}))
    Nothing

testObject_Login_user_2 :: Login
testObject_Login_user_2 =
  MkLogin
    (LoginByHandle (fromJust (parseHandle "c2wp.7s5.")))
    ( plainTextPassword6Unsafe
        "&\RS\DC4\1104052Z\11418n\SO\158691\1010906/\127253<X\US\171995\SUBa\a\ETX\DLEP\1018713\NAK4B\a\41549\183051\&9(\GS\50200\988284\ENQ\SOH\128653Lll\nU\RSS\1007294r-X<\1006885\1053047Y\135696 @\58553\&9\1036718Sl\42785\1065539V\NAKC:e\EM\150993\SUB1i\EOTM\GSW\1026646\SUB1\n\990213\&3T0v\DC2'\1008594\182668I\SI\ETX\DLE\1081008o>'\1063038m\1010345\"\9772\138717\RS(&\996590\SOf1Wf'I\SI\100286\1047270\1033961\DC1Jq\1050673Y\\Bedu@\1014647c\1003986D\53211\1050614S\144414\ETX\ETXW>\1005358\DC4\rSO8FXy\166833a\EM\170017\SUBNF\158145L\RS$5\NULk\RSz*s\148780\157980\v\175417\"SY\DEL\STX\994691\1103514ub5q\ENQ\1014299\vN.\t\183536:l\1105396\RS\1027721\a\168001\SO\vt\1098704W\SYN\1042396\1109979\a'v\ETB\64211\NAK\59538\STX \NAK\STX\49684,\1111630x\1047668^\1067127\27366I;\NAKb\1092049o\162763_\190546MME\1022528\SI\1096252H;\SO\ETBs\SO\1065937{Knlrd;\35750\DC4\SI\1075008TO\1090529\999639U\48787\1099927t\1068680^y\17268u$\DC1Jp\1054308\164905\164446\STX\"\1095399*\SO\1004302\32166\990924X\1098844\ETXsK}\b\143918\NUL0\988724\&12\171116\tM052\189551\EOT0\RS\986138\1084688{ji\ESC\1020800\27259&t \SI\ESCy\aL\136111\131558\994027\r\1054821ga,\DC4do,tx[I&\DC4h\DLE\ETX\DLEBpm\1002292-\a]/ZI\1033117q]w3n\46911e\23692kYo5\1090844'K\1089820}v\146759;\1018792\\=\41264\&8g\DLEg*has\44159\1006118\DC3\USYg?I\19462\NAKaW2\150415m\t}h\155161RbU\STX\ETBlz2!\DC3JW5\ESC\1026156U\SOg,rpO\5857]0\ESC\479\1005443F\SI\1045994\RS\SO\11908rl\1104306~\ACK+Mn{5\993784a\EM2\v{jM\ETBT\1058105$\DC1\1099974\GSj_~Z\1007141P\SOH\EOTo@TJhk\EOT\ETBk:-\96583[p\DLE\DC1\RS'\r\STXQ,,\1016866?H\rh\30225\rj\147982\DC2\\(u\ESCu\154705\1002696o\DC4\988492\1103465\1052034\DC1q\GS-\b\40807\DC1qW>\fys\8130,'\159954<"
    )
    (Just (CookieLabel {cookieLabelText = "\1082362\66362>XC"}))
    (Just (Value {asciiValue = unsafeRange (fromRight undefined (validate "RcplMOQiGa-JY"))}))

testObject_Login_user_3 :: Login
testObject_Login_user_3 =
  MkLogin
    ( LoginByHandle
        (fromJust (parseHandle "c372iaa_v5onjcck67rlzq4dn5_oxhtx7dpx7v82lp1rhx0e97i26--8r3c6k773bxtlzmkjc20-11_047ydua_o9_5u4sll_fl3ng_0sa."))
    )
    ( plainTextPassword6Unsafe
        "\120347\184756DU\1035832hp\1006715t~\DC2\SOH\STX*\1053210y1\1078382H\173223{e\\S\SO?c_7\t\DC4X\135187\&6\172722E\100168j\SUB\t\SYN\1088511>HO]60\990035\ETX\"+w,t\1066040\ak(b%u\151197`>b\1028272e\ACKc\151393\1107996)\12375\&7\1082464`\186313yO+v%\1033664\rc<\65764\&2>8u\1094258\1080669\1113623\75033a\179193\NAK=\EOT\1077021\&8R&j\1042630\ESC\t4sj-\991835\40404n\136765\1064089N\GS\\\1026123\72288\&5\r\97004(P!\DEL\29235\26855\b\1067772Mr~\65123\EMjt>Z\GS~\140732A\1031358\SO\\>\DC16\">%\45860\1084751I@u5\187891\vrY\r;7\1071052#\1078407\1016286\CAN'\63315\1041397\EM_I_zY\987300\149441\EMd\1039844cd\DEL\1061999\136326Cp3\26325\GSXj\n\46305jy\44050\58825\t-\19065\43336d\1046547L\SUBYF\ACKPOL\54766\DC2\DC1\DC1\DC2*\r<X]\986083\97081\CANP\CANI3r\168316\SOc`.\134301'4\EOT\32219\39187\35064\1088605>H\DLE(?\DC3F\25820\DLE\r]\1069451j\170177 @\ENQT\1100685s\FSF2\NAK]8\a\DC3!\NAKW\176469\1110834K\1025058\1112222_%\1001818\1113069'\1098149\70360(#\SOHky\t\ETB!\17570\NAK\DC4\ESC{\119317U2LS'"
    )
    (Just (CookieLabel {cookieLabelText = "LGz%\119949j\f\RS/\SOH"}))
    (Just (Value {asciiValue = unsafeRange (fromRight undefined (validate "RcplMOQiGa-JY"))}))

testObject_Login_user_4 :: Login
testObject_Login_user_4 =
  MkLogin
    (LoginByEmail (Email {emailLocal = "BG", emailDomain = "\12137c\v}\SIL$_"}))
    ( plainTextPassword6Unsafe
        "&\991818\1023244\83352\STXJ<-~\STX>\v\74228\151871\&5QN\53968\166184ql\NAK\74290\&3}{\DC3\173242S\22739;\t7\183958_F~D*f\1049940)\1067330-9\20699\&7GK= %\RS@kOF#\179945\1094401\124994\&8_\42309\GSL\37698\ETX\1047946\&0Wl1A`LYz\USy\20728\SUBo\ESC[\DC4\bt\66640a\ETXs~\USF\175140G`$\vG\DC1\1044421\128611/\1014458C>\SI"
    )
    (Just (CookieLabel {cookieLabelText = "\SO\NAKeC/"}))
    (Just (Value {asciiValue = unsafeRange (fromRight undefined (validate "RcplMOQiGa-JY"))}))

testObject_Login_user_5 :: Login
testObject_Login_user_5 =
  MkLogin
    (LoginByEmail (Email {emailLocal = "", emailDomain = "~^G\1075856\\"}))
    ( plainTextPassword6Unsafe
        "z>\1088515\1024903/\137135\1092812\b%$\1037736\143620:}\t\CAN\1058585\1044157)\12957\1005180s\1006270\CAN}\40034\EM[\41342\vX#VG,df4\141493\&8m5\46365OTK\144460\37582\DEL\44719\9670Z\"ZS\ESCms|[Q%\1088673\ENQW\\\1000857C\185096+\1070458\4114\17825v\180321\41886){\1028513\DEL\143570f\187156}:X-\b2N\EM\USl\127906\49608Y\1071393\1012763r2.1\49912\EOT+\137561\DC3\145480]'\1028275s\997684\42805.}\185059o\992118X\132901\11013\r\SUBNq6\1019605'\fd\RS\14503\1097628,:%\t\151916\73955QD\1086880\ESC(q4KDQ2zcI\DLE>\EM5\993596\&1\fBkd\DC3\ACK:F:\EOT\100901\11650O N\FS,N\1054390\1000247[h\DEL9\5932:xZ=\f\1085312\DC3u\RS\fe#\SUB^$lkx\32804 \rr\SUBJ\1013606\1017057\FSR][_5\NAK\58351\11748\35779\&5\24821\1055669\996852\37445K!\1052768eRR%\32108+h~1\993198\35871lTzS$\DLE\1060275\"*\1086839pmRE\DC3(\US^\8047Jc\10129\1071815i\n+G$|\993993\156283g\FS\fgU3Y\119068\ACKf)\1093562\SYN\78340\1100638/\NULPi\43622{\1048095j\1083269\FS9\132797\1024684\32713w$\45599\126246)Si\167172\29311FX\1057490j{`\44452`\999383\159809\&4u%\1070378P*\1057403\25422\DELC\RSR\SYN-\51098\1011541g\68666:S>c\15266\132940\DLEY\1066831~a)YW_J\1063076P\a+ U\1084883j\EMk\SOH\1096984\DC1\18679e\172760\175328,\5135g@\DC2\GSHXl.\ETB\153793\&2\DC3mY\1054891\tv?L8L\1074044N\133565\nb1j\1044024\148213xfQ=\\\ENQe\995818\1023862U\DC2p{\SO\1099404jd^@U\994269tP.\DC2Y%R`a\r\160622\&7}HnUf\132856m^7:\NAK=\52348>l\95313hwp27\149950jE\fx=!.\DC3]Ar\tw\DC4&\SUBk\194572s\1042820\4498I\146071\61461\1060645dsY\DLE\181922dX.\146295i]\151113\1028288\rWS\USU\1098732\SUB\49884\1083906\DLE\STXN~-\SO6\190031\1110322\\O\185165Jc\1052359\1071278\NULHSo\DLE-W\DC36\170321I\1068712)\99800={\99796h\27961\61707M\1022570FwJQ\1111976ck\SUB\CAN|UV-\NAK\SOH|\DC4;\f\156907\145795\ENQS\NAK.B\"D\163007#o*\126577\32988m\RS\1049834B3Gg;\DC1\\\180659\1098926\ENQ B^\SI\152630$e\39220\170037>fMgC\187276,o\128488\\?\1033955~/s\SOH?MMc;D18Ne\EOT\CAN)*\STX\GS\16268<r1IWrG\195059\145938\9725\&32\bl4\1079274\190780\&3'\153484-8d\"\RSe\26305|n*a\DC1\GS\ACKQ\191157\nKu4k'\1000945\1056819NokNg\RSZu\1060680\&9\141344{JoE\1020205\1032779J5ln\44292C1`7\EM#3\1066049oh\160813?nN\996073vZPR7g\1048725;lF|wC\141456RR85\vVC\EMy%\ETXLjT\175980\SI@X\152574\16984_6\137913\110604i\49958\146144\1027378$@y\71249t\FS\SOyZ\EMA4\48493l0\DLE\SYNr4\GS-\NAK~\SO]=g.\SO\185464\72285\1006719\1066773\DC2\NUL\184316\STX-n\SOHm\165115_;\172002\1109775\43334\1100332W\SOHr\SYNXGC\1004793\vF\SI\129141\SUB\NUL~^~9e\1011753gv\RS\CAN\1073867W[VJ(\\\58715\37252Tp3\ESCz\b\DC1h5\1008688\120915@kL?Gh!\buMH*m\SOH<\187785\n!X?eV\RSmMt\SUB\50146\1077422V\GS\r*{o<\STXu\984721\SOH.5\US\DLE\993739\DC2\1082268\1067311%80'\83369HJU"
    )
    Nothing
    (Just (Value {asciiValue = unsafeRange (fromRight undefined (validate "RcplMOQiGa-JY"))}))