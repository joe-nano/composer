ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �MFZ �<KlIv�lv��A�'3�X��R��dw�'ң��I�L��(ydǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�$�eɶ,g``�U��W�ޯ>ݪ�`;��]�tp���A�6=C�����)<�T*A~�i������(
�D*��x!%���N��[<Ǖm�.��|�9'Ý��-��v4�Ȣ��u�s�}�)��rB�N�Yx&����3�.ΎZi�֕�P�X�ֱ��vl�P)
j���0�E��e~�ϒ��sv{�}@[Uܒ=�e���bې�a�I�|X�M��XZr�֔��#d�Ab�N��x�$��2�����R�%�<wNf����g�?��J�N�h��O�<�q�̿ ē"hA���tB����(�Ś�k�N�sL�V0
/�@�JT�&���椭�����z����,�n�ѵk�����MY�6��-J���@�-ViL���HĲqK�n��Y�d5A�oZ���2��],۪�3$]/���U��)�/B+�1!��x�D����_H	�?������g(.$����.:��eCE6*1�=�Ќ�8)t�Q'�5�7��WV�n�T���ȓ���B���V0��VP8��!(H���1Qx���	�F��)����O�I��(P>)f��qq���.�H�N9$�vQ�(�"t�)��h�F�d��a@1��2�����?���錳~�cX#fVM���|`��1s�0]�&��ǩ>b�Ց����7gX��7�4�4�H@�>�8|2�B�%��[�P�G������]5�q�v@P��n�W�U�Fֱ�^GS:ȴ��|��{tVnP�D�6�RǨ��<L��or>���L����]�yw�	��"$�(���Ah��MjNwj�X>�sg8Ey�Ds�x������ؑN5<�ok����tnK���A���tB���\H9���M�h^^�̰��\��S�_H��d�G�xBx������_DayRbݴ��pYv�(�f���ߌL�dc��Ò��5[n�ͳm� �$?�=�^v#��^�����K�������ߍ�'vuap}�i ��u�͕#G��J�z)��S�o�6+����Y���N  �A��`�6���%:z�P|�l\��+a��>'`$+��K�M�,Y��w�!�{�R����8��	�Y�It��0Y�s��&z�I6��x�����[K�I0�z�-�$��#�dc��1�Hhny"�YT�L\F��mb;�>�&ޡY)H_"�S:-�	 _��M"��1�vb�i� ��A�t7�v��ߒ�XTD��8��/q��� @l �ϧ!L&��O����_@y
&&�5�E����M��CB�G�� �j3��ֱ�m1C#JOf�C!��ࢎO�Ŏ�,�&>a��e�����U6�v���}J�M�
��6�po�*��IM�u-'�AK�kF��yH隦�DI����=�c�t`�78��`p�H�����Y��L[u��c)@x�eS7��#kư�1u��FSL����i��m��b���-�����ce�#`��A����E���`�A<��
CnHm�}��&!��G7l���[2S-�>�Z}����Q�Y�9��ot����"�|��v�����u���/a��d:>���(s����Wl9wc[R����l������d�N����<�_L����]N���B�j�dI�*�4�S�)�����Ŕ�z����V6�,��NdWŖ�hSQ�6�萏
�(��Ã�c�;��*3�j���i����4�N��_D9}����*jp����_H	i1����Tr>�Q�<���V�)�3/��O��t���bz����2u��H�aM�4�q�mӾ�,[3\�Bl�+���lsܶ#���)���l��ڒE�)�A�"*��Q�����n��dvX���]�cڬO�`0�~aCnB6�T6x������c/�宥�`k��E?㸪l;xO����q�:$�y��Q��"�ϫ&���.t
�>���B$���u�<.��WK���r�Ek73�pdd����u���W�,'�-,�{�NGk����y�Y�t��2 y��

t�+��٢��˫�|�<y6�z~}�s�&������ǈݩ��ua3�Q�ﭖ�WF��C��:�n+H����_�x�޴'���MB�H���2F
l�s���Y�D�=Y;���p�4���b��Hgts^�����mȻ?�*�'�lJ�zƧ��G��"	C�o�<C�e�݈�ֈa2ht�?��0G����� O��f�0�����q+Ȃ�5���̲�/���K1���)�l�O�(��^&����aW�:-6ZZ�폏�}��'��35�$�`��AD'FA\\~�^ܫA�[��fe��V��+ǘ�:VVF����4%>�`�	����У�P��mѿ�æ��^�eSM���s+��g�i0�7��r���n��v������O~���"ʫ��h�Hl{�!��I�"�z�B�ܦ�I���R�=�^
�\���T_�s��0�B�'/�j�wZ?E~�^
6_���^���)�9��V�yy#�����8�������@���?P^|��Ypt ��AϿ�+�8���R"�N��H����)��2����;.*���mE��N�T�T/�(�H�}��Y�>��)�ҵ������D��s.�>B���W�V�܂)�g���]��9�+P��t��� ��T9V�*E%;ȒmHA\��p��+{���M��=�q�#b]B�ƛ,ίa;��I��ى��O>ɢ�����3�i�eC;����D�Ӱ7 �Z� kڮ�u��yGy
�ն01�<[�fg0��Aw&Y��)���Z_Z<���R�-L����c��}�}-@�-T���>R~3�Q֑FM�հ����t�b��1���5��!�(�o@�ס�Sb�r�B7(�m46�@�*���DXs(c0�P�EN��tb��`�ǧQ�W=&���} �!v.#>�-D��L�`3�<��k3Lb��d�p� _��,�m~L�!��l�Vu�+�#�H�l� ϣ>��� sl�q]d�N�)�c��
# D4�pO�"�i����=�h����	�!c�����3G���!6��d��l��"&�ٚ;���9�%V�媢Y��Eu0���\�΍'��8�ߦ�����ȶ01��OV��R��{x6�\g�;2��i��Sv1�41��|6��E[}���1&b��jI��A�超g���G�t�m  3z(���B^{��5L�	o�H����2XF���"h�t��	�S�
�-��|�5F�b�Qڬ�|�鱆J�&FL. x�}�G��̺�6E6)0�i1�@:��3N�^O�a��ȑ�B�(�j�X`�j��F#3C�T~Ǉ���z(k:=x$o�A<�����e��T�@n�a
�`�-���,!r��Đݜ��7�.6=��+wM�Dp:P=:xib��{�~�5I_��b!�I�[�&y}��M<;"4��2��F-�� ;1!�8&"��Ge�PÌ���׺^w@ka�C;rO�������>HMjҗ�0%�� d&�a�q�MEv8���f�AH|=�5Y�a�cǌE�.�'�}eT������LS�Y��s�I�j��8�R`�>E�5��:`4|H&�f���v,�� �_"�N��9�< ��5��5�AM�@�F 7`���pXN �z��`T�f�Y�a���ɐ֔��t�����q�)Qs�Yo>L�0���JW#1�����'xw S���o}�1�)��s�
�8v1�@΋	�"�6kE��&;8�3N�E�����߱��Sh���?�L�S��T|~�w!���w�=��w��{���?�v�W��||Ǜ��H���"(B"#������ɤZ͌��2N8�Jd��xB��d&#4��I���L����'�pӈCR�7��v�BW�_"k�Х�K7��	}�u.t|���__���$�/._�<�s��Չ�^�W�|+���.�=�w���?��_��QE���� �_1����=�oz�Yy��}:�/�<���'����������)\�*��}���_f��G���W�e�M�����k�����W����~��_�[��K��=�p��\��e�?���=r�N/�h��w��r\�2/'�j:��B��'�M5.dp*���;�	%#&qrYD1ْ�3��p����ݾ�����Z�r�_�E���U�_�����1�]>��r�6�C�a���2��}��|G��\����o����?����y����m��w#��k�
���j)/5���+�J��~>/�n[�rR�T+�knv���o����:N:�۽\A�ȵ�O:���Z� ���5���k���Zm�ػ��}Tl���$l��FM\u��n��m�s5ږ�+��W*>p����g���Q�a9��Νr��g���:^[u���~�[9l6�J9gR�_n�E��(��߯Iby�_ޯ%��e���ڨ�+����#�^�]��I�I�i���^��T�Y��}�a73hv�N���[�h�z�'4`�vݸ�iv+�"V����j�l�9�ҿ��I�>z͵moW̸�z��֦0�د��n%g�����a�h��K�ݒ�\�jJ�֖��AMR������s�t�qo����tb�cN�a��5��ZΆp�V:�킥;:v���{���[M�s��Z9����Z};�Ɏ\i�W�^��Y�Rm=��`��kݲ�LfA��)K�k\n��!�
=
�`��=�W�Ŏ$�w��(�ڵ����O�N��.�E�!=��t�������H�J������A�c=I����x����:��K�v~`����}7�+�e��g����-��vʾնyGU
�G��v�����l'S�ჭm�.��ҡ�L56�Q�p���Z��g+�Q�(V
��%�'�Z��&%?���T�6��ʭ�˭��ҚY<�k���)G��\Y:`�)�wv���Tgj�n�*���}����꾴�ڔFaڴ��tWAk��]q���]]��Xz^�F��w2;bv5�N����m�o㋕��c��7+clc��W���E�r��\�2�"��?IpUAU7�U��ݶ��<-uQ�.0���s�y�#��{}��%v�?��~w4t��oP������QM�FH}v�qu�h����X�USF��[ɱ��1�t��� a��rb�;��z����:~e#ۢ�����#*�J�~%*�_�x��q,V*Nڔk;NǤ��0�΢�e�nЫYc*��b�L������L[m�g�@�b� �T�����P�F�a�E�Iq/�qml�\]��$=CH�����m��z�Z*��� �|xՃ�X��|��lݷ7's,�n�'qm�Z�ב�Fc��Zp�����Q��|[Ǧ��Ul�ΓaM�^�W��e��R[��EF�)ט[���n�aɗ}��ы��쇋�B\ڢ�,�1�nG�6m4��$�l�Z���@��A�4� /|��O���<�Q!	;�s��]k����њ�G�-~��;x&a���S���; I���Ѓ$�j�ɡIb��BO9�_ Ib��룃���r�?ݑwhқ9ڒeC�8�^�cL�2��x?�V�kU��p0�C\�* X!h`�4Yi�d�O�l�����2^��ӏ���'�0���<`I�Fض�m�N�j��C�9�P�cb��ⷆ�:�nI��!���.6#)��!��ʼg�l���H)cԄ�A�΀�0ժ��F���~��v���ۛx?ۖ��@/;�����m�/�����Wǟ_����_&��F��/@o޻_q��v��!����B����om.�v_����Go����_~_�9�t3�P��Ko{�ǿ:�w����^�,|q��_=rY�߾O��ա�?_��_#��s���?n��W���
�������>Je�Ñʆ�m̗��a��䬽&2�.=����o�;�W`�b>���rM,�SI��b.�)�Y=�s!OQ�w���.=�ꊣ7��r�7�P�D�X&09߹	2w8T��5 �"��s�Re64O+Ea�t+ca�&imkCv�i�*z�b0C���6rh���.�8��I�=�НU?��Jg��c�k��5˔�b�UX�{'F��3����<h���	2��T��0|=�x���Y�����'�N�a"[Z�������Y@�M���(}�
N��~��J��g���n�!'��QA�(5(��lҎ�(B|uИ.�P<�4�����v^��B�Y���^fF�������h���<8e���d�=��M�.���ߌZ�������r�)���ȕ��0�F����{GvS$T�����^&{m�8���	�cqg,�O�yj?uw�J�A����_e2��]z��ܵ��8��QX�f���i���{Rhn�N_��s�����
��ҵ��@"\��F��5���\�t�	��OJ}�Fo�i���]���Z(��B�W�kםe��z,/�o�v*���&)���n�O�M��F���ө���\{%w|^RԋPm�`K�G@�75�[n�R��*Ukb��KQ1���p�'�3{�W���2��L�,U%o�WYd����q$��((��&�S��r���^��������m Q��L_λ�Q1��G6�^��x �H�nɮrҏS�C0�_�C0�`������}�c�`�J��)� w=���P���85~Y���&U�Z3�]�:Y�|</o��!��x(�K̞��i%���FO��Eg$�Cy���a�N"�S
r�(��]�+����!�]��c�W���N�.�s�52�I�j������z`�9�'J�65�X�o�n��5�v��S�r��Q<:L.h�l.6v=tc���ѻH?�}�$�ӽ��;k4�iC|�3�u)q�K���|yG�~S���t;_��u�_C�J�w�謁���F���0ZW�a���ė��y2����M�,�)|[�
�2YDs>�G���KN
�)����O?������~8��;��k^
��D��ogv���Lat�i0��C��Y�w�MztV��9��m��-���_��h�H{�2���{�/��C�#��#Zo����������2��M�#��K�o[��V/�ɧ����?����^[R�.���_w�h���
>���]���k�w������'i�����'p�*xUzU�c}1�����E�;�?�����(F��]Hv�I������N��^,���{���)>y���U��mB�i����I������Oj����4J@�O)��u��7t!D����?{��/���T��'u,��y����3����1��i S�wl�]�-F �����3����?!���w��>9�j��$C��FZ��@����K��������6`����md�c?.r���{��P���L�_�s8�)����/�O޳����������p ������4��i f���g���u���v��)���@��/��p	@����y�\�?I\����_=�� RG.����?$��*�ն`�-Xm�)ն������g�L�����?K@����_.���̐�� �A.�?���p�������\�?���/#d��&�>�k��� ����y��X�����|�C�梃23�l�%q�<wIǳ�Q�\�)��CҎ�X��E�({���?�����#�OЗ�����;��ْ;G[�CM���T��,����N�tݧ��̥:�
�����uE�m����kx�Ֆ?ڢ��@2]m�s����^鵋x�[��a��ۻ�u&�ƻC�D�%�e+�1���7���؜��s�;_���/��^�5Lv�
K%��{7���3�!�����!��M�o����_v�����!S��~�WG����l����/;|L��پ�K�J��[�.�"1S+Ƭ㮭X��i��3��2��=���jbg�js28�E]Uf3�k�(��A��v�S�\ٮ6�V%�Ҫ浇��U��>�&��X����Hk�T�C�Pl����+r�Q��f�L�c�r֟���A.����� �`�����_p�꿬�����}��(�4�h��+�׸�͏֕e�/�W�������J��۷(p�/a���{Cr�7ې��m ��.Z�N�(�0��~3��t����[d����]/��+&D�!r(.��Q�-��YC��R��pIغ��am�nRbm<��
�kuv��?i�
���J�m��5�Nw��4���qz���� ���y�D �GѷF�/VEE ������C�h>���* -X���KNE�z,nSv=rw���q}�w�r$�\)�a���=0�r�,5:�@��h:n8j7�;���^��E�F޳��T���?��5�H����C�[�A��i �O�����K*H��a����?����G������R�X�5wH���w�W8�����p�W��+��5S�O_������T���%����y�<�?�]����SB���y�r���Y�Oa�����������������d���[@����_����6��}^�\��{�!��Op�������"����Y�������'�h�����M���r�/��O���̓�s�0&d�������g�������X"k@����9����̐=��̐,����O^��������?L�i���� ��O� ���`�X�![�O�/��RA��/|������/�O�����'���8����O��L��AH�?������E�:��̥rG�|S��?+�_�?���c�?��жά5uf��)M���sHy�*�v�&�󚍏jeY���,��Z6U�{>�p�"G�E��^��DgTʮJ�qc�Θ��z�~{�$�|H�$�<�ҊA�::t�6-�Xq	tL[!G�D�d�b:!^UBv;׶(;�y��Bv�IF[�F.P`k�ͱS�!�h�8𺘮Ń������F.�v��0�#d��`q�,�������b�_��CJ���␩#�������� ���a�GX�������8d����y�\�?���!W��C��\�8��`�GX��|�ȅ��H��2B��o���h�v�����?o���'����(	�?��I�d�`<���-��@�G��`��8Zf]
s<�fPϣw��.[f�!M�)�T_��y�����0�?���͖�9ڢjb����*�E�r���W�����w��o�b����N�t�7�>c�<���K�t$�`b���;-#��[śT�^�G-�LW���~��K��_t�k[\Ǿ�<��2�"҄����'l[�n�
}(xq|h7�(�I�ahUK��+z��E�7ѱuo���Me���y����gv�6�GS8�-�������X�#3d���/��h��,�#�����e������fj�ƕASR��E�҄��1���U4\\D����h��S���˥@��99-�1V�Y����ء�(�aU�,����!���Fi��sk���E����i�uws���]���Q��b(��@��߱_9����Y �`�Wf��_0����/8��_��?Pf�<�?�"�����?+�>���#gI[�m�+�EtlE�:�X����75 ?��{Z@�p7�8�Í=�he�z��eQ��P3�Ӎ=p&���a5�(�XdR"�q��D{�6�ks4#J�m{ʮלe��X�_�Vn:���u��$:��A\�otwu�r-�q�ޮ�8���skN���=Ū���bWm@DPD���Ϩ�~k���$��$��`:뙪�nC��t��w}렊�זJS~9/{�4�2y��7s�X��{Q�Wt9j��^VP��Hd�В���?ّ�럢���_�y0�,�)��@z�k�?6�3^�^,�Hb/E�<,���Zk5���zYMV3�Cz�y�g+s����ޱ��h����.��	{$��b��$2� �oL;5�]���������8�(�C�Op�? ����a�W}A��������(��_�����/����g=�����8ey����'�ۑo�^�pi�E!���#�50Hx�!C�`���@Ac��Q�����?D������.�*��m&�N};	�8]���x��Ŋh�X9֦�����r�Z���-P��V���'^?����?
>]��f�C�W]Aq�?���h��#��O2��Y��G"����
#.�	�������2��B��$N�Ys4%d!�El��x	D��1���$������H�����晨��ޟF�ǔ َ�Q�i��}F�rH�7���\��je�#�ʷje�o�������@����^5�����_�@��A���������N_���������?�(�������_��>p�)��������`^�?��D������V��Aq�?����P�'��`�?���}���������������GB��� S�{����\�a�We�A��������+��_��3��?��������/?eb�*�����ī��CB�
~V�e�dYL���_v��&<�5������n�R�Ee�L������{������wQ\���n5N�d6�ޅ~p���z�*�)��Z��iyd��+���,Y����?yb��Y��eUlJ�s�{+��_��:0�����`>R��8�^6/��:��t���ӫ�?̊Ĕ�S-��_�|4+��$���?����蜥e��L���N	�}�n��A\��D�Z��n���v�c��֘G���n[��)���x��BfZ����V�T�տ�vI�*K]�"�T�չ�?�8V1�}���\(��/�J�6 �"��Ee���v���ņ�)�F+n��:L9)h�h������d��_V���tD=���Ys����8Trs��~�\Ӯ�n���wI�_��!�uu��=�����;�����:b��i?��:u��L~�4���Z���C������
2 � ��k����}����	����A����I�����O$����7�����:�VC�qN��z.FܴP��U�W|���_�+����U8��J�H�����~��*�5��ˇ��$�L7.��N����\��o�͞^ß_����rMe`Ϲ�R�)��4EY�W��}F|������E\%��'�&��i��â{��tl�3f϶&��I[u���[8^6�h��`:eL.��u����̤���ռ4f�+uM�V��v��.�۽��h�8�U���y��p�N/��)�.-�Ax�$]��ӝ��r�^�X{�-.�YsJv�Ã)����2<Mœu[�w��b��o"w��|x_hNVA�k�L:X�^9�r���|�l��:�h�:T���� M��ӳL�1�<G��{��B-�^ ���Q���i8 $ *��׎�j��̃�/��DB���>' Ȩ��g���0�	?����������_9�\��م`-+���:�>�'+9���X�L�6D��� �i�6�p �r!��k �����}�M�<���u �s!�h�]��a�;*�9P'��6¢�S.�]/��Ƕ^�FΓ(!w�9���O}���^HN�H��hK�ź,�ٟ�`υ ���B��(�x�	�b/��[�Z/g����DgKjbo^M�^��#-�젴6%�4�3eo'y�����0=3Ծ��\��Q�������TQ{�p�z����},��V�ͳL^yv��.ɃZ���+��_x���J ����Z�?��ʨ��C b������:�������_m��������$�(�C�7Oϻ}�M�����׎����`�#�$�J�	�FxʱQ��O�|�i�4I���|�1E�qH�\(D�BH�[��M����7�������p\/�]�(�Ma:�X,�C|@�RK����J�c�+��m���=�;۳����/�P��!��E#Js�ν��0g��Ho���4�'��+���#S2��f�;��-���e*��a��[����VG����}�����Q����Q���?�6��w��Q��W����c�dN�}�-ۍ�����n��ڬ�\���m�ڟŵ�
��?7����º4�^�%�ۉ�L����&8f֡��'���7Mo|����^&��I7�����(r�LK�2�Ck���'
c��{+�x�S����:<����x�;����P��_��_���_�����*��@X���p�a����g�_�i���=��:Ő�}yˮ#{7;�Rn_~��������=���v-)��XG��q ���Ժ�m�k7n6Zǹ�a�6^G9�4����?յ];�H���gqgG�F��ƌ����^�d�β��nή�����ڙjQb�c;?��N�f�?�:�V�o{m�4��߅��+m���g����Y�G�����~j�ǡԊx��vR��u�ǬQ��v�����h*��k�)�6B˜�I"�"j�'�>l����=��pjw�TҝQB+�:���ž�"Y�km�4�Æ�7�՚�6�~�^�:�� ��*��V����g�����?�P�g_�?��!���|ך��_����_�����T�����4�E��������V��_���?"��⥦�����_��$I8����+^�D-������� ��P���P���O��`�KM����:�?���@����N���?��B��$�����_���Q��������W$ x��!x�ڂ����_CB���������,�?
��?��T����
� ������������yu��_�&�#�0b�0�"��q.	�L��0Y�R�Y>��(���)�Lx!����0��~�E�����"�W�z�a~��3^N�ĘiD��|jY%=�6C��Z&]�L�m���iE�u��σ�����JW����c�t�Ւ�z��܎z8�L���?Y\��(�4��H��oe��S�6�x+ux����<�Q�@��>�����������QP�'�����	����j	*����������?�����j����U��/M��j�����*4�'QF1q�����D��<�gTL1q4�Fx�4�p�)���?��LC���_��/��h��OW��k���٦�������G�ǻ�����N�n���9J�[r�����ʣR��_�����{�1�B��S�e|�粱tƳm>t���&)\H��p��'�����R��?������.�������(�OA�u����A�Q�L�o��_���P1����������AB���!����r�'�?��P������_��3��?������C}(zP����?��G$���� �`�C�����G����:��i�!*��׎�j���Z�a�#���/�$��Q��h���������G��'�=�㽘��a؋i��
�7���ݯ�����om�e�Ϧ���=�3��kޚk(�<��"�3G^��&��g�02dڼ�w��k�\rF������%!_���h>�ѽ����x<PWkY��{���_�}*�b����N��Ҹ[��$ۥ^���س���\��c�Ѡ��v!1�x�8��Yr���t5���1��,J������@��=�D���,4iI��;&°���r��|��å5���n�"�{�`�:����������k����A��?"�f�S�S��h�͂�G���O0�	�?����������U�_��_;����������x����#�����������X~���hz���8'MI=#nZ(��ҁ��E�b�8�{��)��I����D�<�&��X^��!��S{&z���nkx��TR�xپ���eL�'�G�
WQ�spQ�h2�F�.0���OZK�ט�BZ��|xa�Mb�t�Қ���x��I�����5��5̟I�-���T����!��g��,}�w��ψ��R����E�EI=��I�	u~���9k4��ٳ�	�;nG�Vݹ?����CC4�a2�N��`]�xk��;3�;l@+g5/���J]S�U���[���۽��h>YuǔČWę(������=7eCԥ�6��K�u���Xn��A�a����6kN���ax0����u�u��碩x�n��ΰYLV�M�S�/���*hp-�I+�+��QN����-�V��BY��^�w`����C|z�i�;&��p������?"���<=���6����_;����S������P+�O����!�g��ᙈ���(�S:�#.��8�X*d�����b6f(�������p�?�$�����K70f��T�����b�b���^�B�:�ڬm�6y���������{��4rd�
-�$�pc����Ml�ó�yE����n��d���W%��n���xoQ���VK�R��T���S��8���Ձ�a�b�zr>-��Tyt�<8���?�4ߏ��L�k[�J��W�J����lN��vG��n��q��M���������0�o�>]z���ѷ��O��������.=�����d�9��p�����^z���=]����[_��'�7c�c?�oG܋V/W��ίO��b\]\\)�mf����UO3�F�C��LhyZ�ڹw����#���Dz�����7��u?��ۙ�ج�h����q�}�iNr[i~|_-&O��N�bw��m�����ٮ�>Qz�B�������s8�����ti{�k{�k{�k{�k������x�gk>Az�8{�?����i��w��~nv����:G�"e��S�����j՛���ի'9����z����kk�#w "<�� D����; `�*Gt媸�R��%��w ���=3�:?)&ޜ:f��i����V/�|s�(����N��v��:*U�o��և��ɧbU}�߭��݊U���_���޺گ;���L"���K컏}�����[�; ��K���V�_=,��)^mpa�����D��d���R�����X�X��0ү���?52�]Ϟ��g很@������|h��O���N�#�O���M�xV}_�U?�$O,wt��S�w_�қϟO�K���W��3����Cvd_5N�Z��'X�lt��L��;C��8���r�qoҿ)�S����λ�/���4���?>�C}]k�.�M��z7������^��9�ZZ��Z�ެQ�u��0�&-��B�G^D^�v��)v�)̰Y��2��z�
�8�ʀ���$������ Z�a��▆%1Ra=���� f��A���A��чl^���쟌R �B����� v���-R1�T3
$`�����6B��GL��f�4��h�.��	�AM�3�6��`X�J�?"a�M�18q$��|F���1��� ,�a�P��O=(�r�3Ν�:�}���A�g���f
g�$̠]�A69隢9 "A ��D3��t-	O�Ӯ��*N��!.�t�L4P��M��E:�G�VH�� ��n���Z�b��	x9��l�]�9`�7ŶmQ����$0U誔�sGȫ��jS_�΀K?��Na��Ħ �}�z< �43��\eP�5�'(Q͑�f�Q����T���NX�\����Hp���[1:Zp!D�;S�۷�����8�	N����	d2Ѐ�fׁ��>�vLu:س�!G�샆�RW@�m�%�G�hc�O���m;?�=ӄ<m(E��(�,�E]	�8�M��n�4�����u�Lu��R�r�B��(u��"���)ON��igNl>�rQ
)���д�T%΀��U�`�ɾ�h�Q]�J���/�E)�M��j׌Dq:�/5*j%Q�M�pb)��>�.L~ә\"��;��4򙐼�^��рwp���ݐWm|-��n�����C����UE�7Ư�!�� پnD���	c�������R���'0#]�HxR���N�Wf}�-z��rwFt+�� �C��
�;�|xy��u�F��9���#b�
$%_A�����g�D�[�:����c���JH6y8q:�y��dIҠ�P�[	U�f�K����r	�D��n#�ݹZ�D���WM�Y1��5�ӻ� �������S�d&�JA~:�Nm��=J��,��闑� 8�����a��i�z01KgjxB��B;�V��y*���,6֘0#�1�,�@�v�oK�Z��\�<n�U�QK�J�\R�]m}���^K���Z#�r�^4lW�?B;���@��)��|�b��ųJ�rzX�k��6I�
i-`^���@��i7�K��n2��̫TM�YVI�}Ji.��g��^n�ehW�V�I�ս}�ͳ�Qvi_�X���[�w4!1�%�����!�+~�]�&
��F��F-�.Ť�b(�g�Ȗ���\þ���x�ѪT[��G�z�U<�<m�V?TOT�u����ڝj�X�����A2���,���k��j�Q9@NYW��v�D���_���� ?ˎwuP�wt�\<=k7k��l/kKWj�E�·$4>s Ӻ�RլI�#'�7G�$lKI���q����,,�f`IkN�Aԓ(��e.X|�]=r���%����Y�N,�G$�b���֗o�/���eװ>V�ߗ�*2�Q�~t���y��q�V/7*�E+���Q�至�j��l����n
�D��ĘZ	�5������k6��|��w�<\��d6I-�Vi�O��q��)7ꇵ��z���:9��x�t4iÍ�d��

Ь�
��b�xQxa_jf�P�A�v�ة���b�X*��`*�J����y��R�}�o���v��{ٟ*����?�bNL '+�V��gl�(��c/i�Is2��Y%�>W�L���'D�Xlwn࿳]��\��O��F�P�K0
}r��K��TS�,��e���b�.��d�w.QT���y��r kf9���J�!C������'I�����1����q�f�[k��d6������3���GIB��H��p*&5�A|�^�ݠ����%��v�+O;"8�Z��4e�8�p<'���3r�ڝ�˖�wB,�a0�U��e2�s��L`X�=�*��,s�#5�����[���n�'�Oͭ��f����GI������v�g���]�ٮ�l���?O��#�Ǘ�zT�7_ �.�l�{��=�N���jN�C�5n6oc]��|:?��e��ݭ�����]�Ht�=�c��<i��f�a�eZo����P]�����ٹ�*�0�)�\�EP����I���E�����Z�n�J��4A;1��(*������s��e�q�*W�L�u%����_�h���m\ l�aW��0SEvD���x��m��������#�Lb=D) ����ͱ8��uNk������z�q��@i�C�$�$����P#;�B	J��I��k��t�5������(:����mc��s���i�������?��m+���^�E���C~ͩ�#�O	����(?����|�����~������`���S�|�'�KAn.��?���V�#�����~n����5���)�D���R��2!��<�_�d�]�/�k�/#"�O*�8��|���O'p����T2'��`���zL���3�aȻ3r�h�!��6D/�j@5��_ "���3��
?i5	BU�Ʃ�m$Ҥ��.�V�E���p�O����I��~l"���P�,;)�^~�0}�9��6k�Æ81�9��&� m�Mb�׾'�%{��Q����KE���b3!C4Xo�Κ�Vg�AfS�����{�����|���?"���u����"�(��S���iw�(�?�� he��k1eV��7�B��w#��@!����.ve �4���#�5a����9� ����5����o ��N��T�5�r+�9�v�X�I�(��ad��ej����o_x�A\�V�������L�oB�$3h�O����rnㅋ����!5v^-�Kp�D�Yg�"ƀ�Y�f�J�u� ��9��>,K�A↌�@��'��!��Tظ�g�˙�ǯlӈ|�������I-�Vd�Ĝ�hY6���t�!3]�g�I�Mv�p�ޫ�+B�7�^���N��������ǿ9~��$�ߥY��e�j��a�( h1\l��M��X�+�P�v�bT�#-�s	?�z��v��s[������˟+Y�K楿��s�ګ�����eo7�`�o���3�6�G��1�Y�]��~���ή�Ƥ��@�X�u��9[���D��+$)�ô@������RH$`Ҁ��o�DW4�8�w↍��G�����U���v���Py�r�3�tvS�֥�s�$�0��ncER�<�~^�}�����(X*����d�\��T�{��^oo���lwO�Ϧ3,�����4�d�I����t���S�O�����}��+�����7�%���S`��m��S.�*��N�s�p���o\��OWq�Lg�k��҂|��4j��Jb���'��ć�$ o�)��Ɨ w`�,my&K���I������0b8�:Xb`�����-������2jb�g�D�H{Xvd嘐%Uݙ=�������U��$]��,S�
�Ƿ٤磡�d��R�_
I����3����12@ʧ�u�i1�s��c��p�7[Z�������J������H߻�+4FM:���#�`��%>e<�ԝܦ�iC����h['�I��_���d2������H��??��0�������#��Om��%�����gl �����p�������qG$�bG'H�![�洐�M���4�/��,ɩl�	8)�v$�H+�z���h���_��7�N�չ��Ϊ�F��S[�H��ηeeo#���h�W�Nܥ�%o��c�)+Θ�S}���V�K�l�z:�s{H�N-��� ��L�NV�t"�nm|��?5w��݈0W�n�;�uy���S��R��T��)`��/������Lfw{��Qҏ�҆GԜ�x��2<|�CW�j �%*㽉�S������C��xv]��u�MJ+�ߧ��u�Mژ;N�U��M�ߟ����6���ʧ�����{��7o�[�������*�O�����l&�����&�7�{�o���(�b���z�O-�H�ޡ�a��,⊐F����j��dD-��~^��N����Աٟ�/�#� ��ߗ�]f���Ц����嗊�Dc�
�6��u	��W
�_�P��U�o��A�i�oUr���_X�DaI�~��c��֖�&�����>S��^[!����`$hPTB��?x���D㢉[�2b0��Ѐ�-�+) �Ϝ���~V�#3�3(�(�7�o� ����2�1^y����C���*1������ƥ_u����� ��|��;�&�`"�
ֈ�_���"�'�.b Is4ޢ$o�x��\+���c��#<p�ɯ�ߏ���*���S�P����t�����"@��]��b[s�$n�E?�5y���	�L�*�{ޙ��^=����k=�Ҝ���[�� ��MpWmD�i� �zV��"�A����p�~��J�~��amNw^�P����s�E�Sh�ب������DP�g��HX�m��><h#����>0���Mͣ��К��h=��r��Uy��i�����khvㄠ��w�Ξ�&�G��\nƩ�;�F}�3 k�g����ďES)��cæ��iq`a�qM+��b:�l=3�f�������_N2�t��a�=1=C)�ޯ/�u[ɮ��'������Q�(���k*�_�&DXD�]TU��v���uR�u���qT�/b�g�t ����]�3���8�R�ź��I�a�m�+C;�p,S�炯e~	�C��Y`<��0B3
�!g�n0f���hCw�� ;b�P���!�r�7��޵�8��������3�3�{n[�KS�]�dfb;�ăFߒ8��8q�4Z9��8v��'j�.�Ђ�e�o�������V ļ x@+� �vn��tUuUw����Uu|�s��������_^m��l��y�y��v�Yf�xy�V�gۭ���������I�>�kC���jw�c�Sܲ	��e�T��l�.;׾�����[x��{@��,��'84�ju�^����՛4�;q��^�v�<�7{�@p}�Z>��?O��h�tM_<x�o��n}^�Amq`���%��1Y��Ն�2
�����}�4���I�d��)�FPr�y��)��)6��,U�U�~��E�|&X�fciP:�/�/�Y�6�>�S,u[s��
K�8�)?ur<%6��vD��!8�#6-��<�"|V��y�W�m��\c���6.������!HA"��?ǃ�o[����[��n�9����'_<z��_���H�cJE�u��`�ڬ5�z���f�B1�T5�0�jT���SR#�8Z��8���wo���h�+्y� ���2��_�x�zz@gW����['/��������;s�d��r��������7�ΗJ�q��Л�]�җ��ur��8QgY����������_����D�۸d�����?�F��������gď����o�s�Ͽ1�+�o~����������������~� �;��_;�u��?�s�K��u��h��!FD�����*i��!��Z#�P�p���S(�����xS�Rh#���Qt��ί���W�_�i�����?���O�=����0�6�6��्�i�߀���y��סｾ$��y��?�/��,�o����C�t|i�l�ݝy��`�m����*��%k�V4Z9V�Jh��]p�N1��o��LV�9�������:y�7�F����U��/Nn��y��k
_��*��RA�8�"��\x"�hTlW&b[��vU�ʦ�2y]Ą8agtr�\���VQs��/nM��W)Mz�5�u�����1z~,��������d�֑zuT�9Ӎ��
)~�x�_��;E�RB�Z�0���#�\7���p��H�J?�b�ty��X& giy�����:'�4LE�
�EMsf���4��V8�U�q�~�7L!3Gj	�g-͡c��\�%Bf�f��4�#}w��s«��T�)��s�c�;"]��D�L���v9w^YYT.���3�ݛ�Ȗ1^�e=�:V��zu��B��~T����b�X��i�b��V���N���K�hAg��v�*�����	��Y�H�AH�a�Q�*�Tz��B�l�8��K�����v��j���8� %�4�rS����)�������gS�=N*/�2vQ
Ma&>�I�˛�|&�|}����������7I(�$���\�P�uK�+�%�>�3UpiB��(��027'yE,v�cR*�T��;����dv�,I+WhV������a�"Y%�=��JyR��l��b�4�����0i�������⻲?�	��B�x�3��#�
ri�Mu��N^�j&3��!hO`�::��]�E��
2�S2X^�ה��E����pˮ�HN���]*�Ej�6º�����H�i���=�\�"GyP.���
S��qC*��r�3���	�����D�.�(y�;�����e�QL{��T��kOϊt'b�����F|2�칉�~���\[� _�\O�D݄� �e?�µ���Xɟr�9�#����(2a�t��H� �%�PoO�qL�R�j6jt���$m�l��T��s��-��s�j����Xɟ'?d�K7C,Ma�
�/�g�:��DF��3���p#-��>V�����2�1�А�븛2΍ٕ�NS<�$�n�]N�������j|<�*D�Z��YЀ���4�M�3���Y�6��k����{&��t��y���×|�m���O��-������v��B�����0�i�٭ٮg�N�_�^�l˃U��/녗����J�;p������//B�=s��%�A����y��7�}l$��~���/��܇�w�����~�]Je�Ge�X�Nt�Q��eJS�'se�Ѭ�����e~���+�Ϣ��}ݍ-���]ܟ�s��њEOx��\Gk�d.��.���%u��i.�La���|75�(%�V��s,8D�q%�����23Cb	rD�D2���Z�-��b�q�Au)Ӂ�Z%2:p�j�Zu�f;5�>��]gR��a�Y��;��n�d��D]PV�̂e�s?�je�H�7�.�Wx�w����� ��>�&�";�.˨5~�1:�t���I:j���h2�*�|�U���9�S���ԥ�1<m�FY���r��(�B�SD`E+��Y�x�㵰<��<%Dk�e���[���0KU�v�$��X�.�V><�
d˼H8��K'�+ʵ��,W�aA(tdq�N��tf��Z����{�� 2�J��O+ȱ]\)�\Gj��#X�*+s
��Tj�S�3����ʄE�.s�m>�����}5��\�oӕe�<�/f�J�H�_M��Mr����gh�bYg��V6�E+�2��UN���&��!�dȅ�V��LL.�9U7שR�g\�e!K�Q�m��D�J_�D~x��h�v�2�P�Y����b��Vv�.��:��r�Xb2֭�(D�Z��gӉu�L�/u6�ψ�w��,�hQ���hV�W�Z2Q2�B��'��8	�HSp;j�*�I.�xF�,Oě&�0���u{�:|�j!fF`Tae�M���H'��K焤��dz,HDiܑ{v� G"B1�FK��g���mW�t�8�$��J��u�`ĸ;&�K0+a������c+a�����@�6��%��#r�XO��А��Yd�U��Ԁ��f�g�t��F�U9/�(?)=D�h*_��8���
�n��X��hl��5�%�u
XI�s
YHW�~$��}{��ڮ�'�ᄌ��:�s`���PN1�Z�0h+m��cI\�MF�(��B���$K�; �P\C���ga2F!�2n~R�Gj��1q�\��fM�j�^�����M��^9�K���n襯@/o�n�е�x�s"�*�OZ����/uќ6t��a<�V	��Ws5{8�h�{�𢿉f]�|y��zz� �{���֣G�u�^�����n�Ǟ�����,dE�2�M�@W�&]�Z?�o�{	u�2l��t?@T���`I���||e~�����`4�"�t����uu�[�z3�C���mCz�-���r ^X�p<��o�5�O��U��:��?�U����9��PWi���b�O|�E����[�Gː�G�=zgq�8��Ѡk�Q	�pj��ͦa�x�G�Q���[�vټ���ң�?:�#�yi�͘3���4��ׄ���G����_`E<�o��pC;�}S/�C��n���M�P�:��'yCO�w7tE=�o�zh���о�7�}�;��Xs�}����~/�a�k�iþx�����sY�'���	] F�_x�~F�9�����Y_v��)�)�o����F�]�z��4����E	��� 	��m`CO����>H�y�]p�mU*��WP�XR���Qx�hI��f;�����Uc��k�Q�Zc9�����bI���̱��Mg]$=4�	L%z��*G�|p�x��L�v��>?���7φ}I��oғ��'�o+��[���z����G�����������vf����=�~���� ��V�i�-r�l�B<��E*�]�WeY�a�M��T�S�Y#�j�.�y��I�e����g��l����K�4��١\�r=�`�b*K�fE��Z�PM���h�r��1K��7t�U���Hɠ���0WM�\B���ƈ���n��gnl�O}p���Q�Jm\�����b����p�p���n8���:���&#h0������xb~W�c�A�����?{������oGx���2a�w�q���?9�c����'������l��)sN�v�����=���]aW��S����?����?
���p����.������ա]"����w���s��	���}����k�]�𽞶'�?���_���@��?���
��}Aؾ lߓ�����}���>g�G��m����� �
�n��Ϸ�������#X��
���������a�,��?�� y����@��	�c������?���oإ��X�`����Ϸ�����g�$��m`O��k�`����<����[A�m)ȶd[�N��]�ܧ�����gإ�������S��������ΰ'�l ������;C���������^�0�;�.�?S���@���!���o�o�?������A���`/��N����(��U?}I4jM
հzSm4#Q\�Ȩ��1��l�(�;�cL�d��	�[�g��~��!���������_�8�A�:1�#0W�*lb��^
%)�C&�+��Έ�2��"�͌���d�BCL����:�`H��5�<95��-�&�����xՎ��^�G�Q�9R�2a��4���y��Nc��swؕ�w��������>��cw�%�/|�3w��_������4�?F�E4>��h)\f`����KյAɕtݪdXr���#��_�)�hfRF1;�������N)+	��G��؊Dc�����z��jI�����7�v�d�Ԍ�p���P�쿫b?�$X�����+kO���_q�}��y�8 ����8ݜ�@�Y����;��t����^W�1�`V�U���E����>�E��@D��
�A��A�����+h�4`� B�	���@�������_��k9q��&i�A��ԟ��֕�O����?��~���V��&����Ư7ۨ��m*m����\���Vw����Zw3@~���Ò$k�qPF����R:�P��&Q.�lcW��:��^�I�!�u9mwm�h�}]��*������[Y�6�:y�r]�x�M�N�����C�B>�4׫]ﻮ>h��c��_Dߎz�fۨ��,�E��R�Q/4�u�|Uuf��z>;��n�0�T�C��Hh)�ix\����7���8�3�BYU�TJ�|�^^��κ����V����Q�V`ҨU;"��|z����ל���9	����w�?��p��C�Gr��_4�����GA���q '�C�G���7��� ��0��?��G��X��o�?��/L���Ür��k�?��en�?B�0�?�y D�������C� ��_��B��?迏Z�a�� ����	���8`���@���7�.��`����_$�?F��_E����'��'8����?O_�����x��ҝ�?���l����˳X��?�����w��(�����E_�/�������
C���!����p��o�B���()���}�x����X �����������_��0�p���b�)�����#����+
���g�6�G��S�q��?���u�Z��b�G};�4j�L��֦ܯ;q�z���W�?���܌��S8�`�Y���L�j@��O�׀ȇt[U��^7;mȖ���(m��q'ium�v5�%��e����O�(�Lm�?-�A�X�ļ��t��b�;��k@�kȿ���E �T��ռsq�Ʋ4U�DuK=��|2Mq]�&[����i5Uk�@+�[�4!UV����,df�z@V{��yʆ�(��hȸN�O�_�οD�?���������4�,�����#���;�?!��$�?4��"������,������?B�G����
���P��������_H�h�D�8�/���?B�ǯ"�����P��[��4��Bp�� ����$�?������� 9��+� N�"H�Q8�h���y�؈eiY	&�h$�Q$�/��"K�D�?����g	�ω��������ow����o�=���Ɔjk����f����f���qn�4���uo�u�4��3~-���8��Tߤ�=�A̼���q�U��p�)�iG�W�N��fȖ��$;d���I���>^,����|��B��0��gyƖ�g�]�fG�8O��8Q�S�M�~j�s7��{7/��NHX���gq(t�ϖp�[0HX���"�������~����/ŗ	���8�I�����t^��f]+OhJ//x4�kκ�4��ú�r����>�?�[9	[��e�$��Fs���J�4�J�S��C��K~��''g}�s�]R����Zb:��r�&�U�L��qͳ��~d��7�_���
_��-�}�+�w��������/����/���W��h�b@���_AxK���/����i�������=dޖ^�ĺ�z����O���H=��(-�t����mrK�����Q�:��r��`1��}�a.�I�e.��e);�bw��MW\�^R��,�f#HҺ_c�q�ٶ�弢-�?�<��4��5�I�i��j�#Ms���_�SSu���ە���{E!Sa/9��,�����aU��nE.K��(�{]�s�����r�+6V��Y���e0~�#���k�z�z58@c�L��t��I̠"���z���u�SO�x|r�^�ɭ�uh6)�"�E(Ys*���h����o�Ʊ;�F|��F
��	Ə�� ����翜�Hp��$�F���i������Ӌ`��o������DQ��0����/���_@�}��/ 1��P�e��"�e�'��x�H��0�}1HF2}�Jp��X�2��FV8(��@��o����������_�&��	���j�v�:*�(\6JG���h=o���JP�=����l���we��~$��̽�꿰�����;y������E��?����pS�+�,�?��ɿv�`8�K�|�'GJ��<̋��<K�b�)�$_��}�A!0����^���X�'��.ƑZg{�=�>M��n���[4߇��/�+��ӱ>��۸�˴2�;q�kZ�߯����f��� �Y�a����������a������/�����_�����5������{	�����f3?y����ث����� ��1���OL����}z��E�N�}�����W� �� ������?������q��q(�������M����	��uLї�K���p���_�� �����/ŗ�?���/��� �cA��o��1��.����������!��o��y�����������T��R��+�PH�^�鯒9s�l�iNU�R�������ٗ_t�8U4���Ƈ`%$��1�5�1+v����-c|�Fa����?c[�yj�>W_�]�u�*���s��wPQ����90ʮ�ߛ��N�z��1�ȫ�S�]^p����W$e�l����Y�^���eq���b���s�~�V��vZn�Sc,dyo;J�sΜ����2]��Zm��A�VZ���\�:�.��������)r"�J�z���j_�]�zMe�+[�"^����ՑIi��'�sP���d/W�"�j�*�+vce˭�q�͌}Oݢ�ׅ|��Ńk7��h���ɖ�:�;��Q��r���Ko�i#d�vFy)�K��'�Jq�W�I��΍�>�X�px�����uTs-���{�c��5�$���r?�?[ ��wo�7��a�/��k�(�����#���?�?��������`�A��������������/�?8�ֺ�N��f�6Ci�1K���+8���/����S9��?7J�Y�X�U���g�Δj��>1�M���3�X�gѭ��������sͿ�e��V����b+#�5�q�"�������ߩ���?U߫��j�^n5�1�n��o���F��\�D}J:��V[7����x�5�FM���`Kci���t%+�'�8捓�y��5m�7��r��Y�{[�u�~��U���}��py�����P-m����Y�B�:�E�Xm�U7,�j��JU�gl]���mu��e=�ѱj^�r+|�pE�b�[�7
y�a����qI�-!�^�W�I9���7+�~�l�#A��ۊ��Rþ]k#zv���t�8^G���]�"�s����� ��� 6 �����������/�������Ol �	�_`��C�7,x��w�������q�����ό�8cz٩�O���l!��?���\��P���� P�`j��� P���z@~�H=��?��yw�z�ѹ-��tǔ�{�Ҙq�l&�=/������Q5v1�'l��ú:�R�l`�|�C���/'J{�c�M�oP$���9 �9��4ިQ��*<�(�3��y�b�%_k!u~Ι@�Xb�M��M���9��Z;�J���FUCf����R����z4���I಺������zЗNm����j�g�7�Z��MM�HG�"�*��,��ϲy@���_���%��� ����D�?���@�C  7H��p�_�����������
D�?�N�����ExJ��.�_ ��m�G�s������cI��01�ӡ$�H2Gˑ��Q��r��,r� �DO��%������x^�`J��A�ߛ�����7���fSklfee��Ej�R�t���9X.˪�N�]����o�ݡ����Iloq���T:��Ue�)�aL���wr;�I�.C���XsW������{-6dQ��uoj��B͞n�
��U���C���P���-�зP�����+D�?��(�����v��E_�/��_q����p�p,e�^^-�	���QX��ۓsǼ|g�i���k���z�"��K�\�[���M��l���h8�)g� +�̱jm��h����y�����n�[[o�86)�9�5���]��SCp���*�X�Y��-����>��@B�꿊�A��A�����+v�4` B�]��������x���Z�����O�o�\ePى���M�Y���'���O�Gmw�v�6��&����:����\��v���K�a�lE�[%~L�����v0�j�$�t�l�����t��\���s�l#.u�Ӭ�	�;�rR���ԭ��OW������U��׫j��]�;-6���S�M�Y,�b�Z+�q;t�C_�}�9g�z��W�%˔3lq�V��^#�-T�p+VM:��V���e����f���P�ЧV��qu�{�d6�:Ӭ�p�1k��63�ˬ4QTv'��P
�[nQ�։ m�����$�?��S��������J2p������;��X@�w��� �CWR��_4�������+i��������W,���0�����B��x����L���`�� ����	�ϲ��v��/D��'��A� ����C��?迏�0�T��������_��?�x!
$��{�_x���0���������+����N�?�>~�x~r�������<�H������� �Á?�������_���< ����C��P�'ܜ���WL������|ߧy��&h°!�HA�"��-�r����;Q%��ϧ���;�{r�(�{3�����]wex��"�9��Oh����$�L��:i)�]����.��eE#�+��es�aaJ��0��߇�)���������������ð���{i�Mf�a�"҆B�z����f\��1��Z���i���C��Wn��X���̤j[RqH�w���<h֌��sc87u�������eH�˘�PeZ~���R�J�r̰�q�$=+��x+�����7�����x�7|�K 'J���������N��Ԟ����C����4�P���;M�����������������l��e�A-'#/p�,9b�Z
a�"5eD�U��j�ͦT�ɒ���i�VX&R��(��x	�c���}��x��a�=�����ư<ò�n�/����.Y����'�:�����-����[���&�2����3v$���ե!U��!Qk��~�kLR���Jy�|?X�S�촯Gﵜ�Yz4���ٰ��<i����[���8�<�x��Y�m��J�����S�8�:���=�:��CС��%����i��������g���/�#��q�#S��1��S{����A��?�2�)�������g��D'�����G�C�����@����!(>�!>�!>�!>��������?�N��s=�6ı(��m��$�?��]���<����>�N���������W���A�������:�`�q�U.7M���ڝc��ྷ���\o���ު*�������F�;g�ŁB-%ń�QK0����5�Z3�MPr����:#�`Ɩ��"����\>kݕ��S��2'�v�jej����=���C���/F߄��#�~��@��7����ou�ۈa�)��2cP�{�(ӹlg1��f(�mh���u��גE�,�m���%�	�U.��|/�FL�z�R@�\M�	�a:g���Ymм�����$�������=�����q�c�ƯG���k�'���=������������C�)��������?��?��?��?��?��l�����8��{�ף�����������?��s����������x��x���?~�_6����u�W;_iI���oX��f���b��r�ȧW�^���V�D�aZ+Es��s_���F��N���|�Pg�ߚ�*�,v��(������^�7�rû�vz�P䲔��(O�#R�1Q�����j��Q��D����w$���&a�I#�^����e�X�V(�1L�f����4�?J��ȑ��ly�7S��ݩ��ʂ���r��2�1�ou���U��{���r�+d�m�*;d�� ���Yɭj�VfȈ���'�_�rL��>|>Z��c[��\5t�[U�eEn�qU�}})hN�B����3�}����*Ӡ<����P��z�!�B�jP��#�~�����N�H���]Aj
�[nfA��� 2Y�>���ckx��4l[�n��--�Kz;]�س��J��8�E)��X�M�����L+�ɱ��mq��?����R{�����x:�o
W�g;0���@���k�����Y�������)�6RR�:J�4�̤�t6�0�4���HBF�*��fU���r�U)ZQIZͨi:G+$$�o�8���;�?��C�y��{_�'K���B��!\��.���r>�r��"(M
՛;])
����٬ֶLk�Pı�Ksb���~J����2t�7�Fs�Z�xfт�:l^wu��绕�XA[S�I=�=�j-%Y+�����Na����<y���x���t
����N���?�F'��Q�	��3~A:������{�~�)v��x���:��	�e�y.ӝVQ�&��DM��k��O�Й���F�`����\���L�'��(h� ,�9�ɖ�ҵ������+3�K#����ςLઍ~S��2��(�t����Nc�������UN�οc��+�)����:�����_���x�W������b�t��>���tl��^�������3���7t�+
���[Y�S�!.����&Gy����6����K kk�g� a��@l۳{�  SU-�Lu���T	�	��= \s1��V��%�+�M��m���ӡ3"�$_��J�����VQ�W�s���U��'j�l�v-+yGX�!�ޚ�$W��D���{컾�n>�?l��� 4�>���px],���$��6�)�+%u�k�E��+�Խ�\C�~F�R6[�����[c�e�*��	���ʟ�7�7R��)��o��w�\Ul
��+�eǟ�YͿ�W����\�c0�K��3���3w'�
g��K¶]�:Ù�̮���wW�g}��R��jڹ.ߍ��>h���b%��W�x�3,C��?�fH6��C�' ��c�cH|]9��L�p�Z0�-A|">�v#sQ1Th��BҠ�#:�����^P	�C/ޏ����A'45�3p�pdX68�=��f�%놥���`�t߹J[��$ x_�ߺ��}j�^n� @ޞɆu	��0������s���؆4"�
4� �l`�1���а~Pmª\�?qǔl׳��Y����o�bla�oj�Q�>TxC�������h��0�]�~��xc�.TC�l -Y1!J�HO禡R�m#�u�a���;k~�D�;�\% ��<�G���@0ȸ('�D�'{��H#k>a���l�q�.'�zy�]�[Ds�c�
���J(�� M��ַOO4�/-x�Ծ��8�~|6
g��2R�|-����mE��B�l~�'��1o�<$,�=h#��14����.�g�j��.���{4:�.�˝�.���Gb��o��*��o�ξ�$��m�CyQ��o���{V���5-�NH��e��α�-��J|�ho�����6J3fѠ�+p�R���ζ��=�(/������(�fp݇�.�EBUh�kH�< +(��*)��B��ǁ�F?_�ign8ц�� )�3ہk(��2�"t�:�JC]v�c�O6�՚a(x�$�k�i�S�טBp�����΢�H<��[�Ej#v�G���Q/q--��i�0�	��𡯿�7���Ұ4�_����ݺ�����G�bh�_�"�XU�l��kbGk6��l��C�1�큙���C����"-BX�iG��(�7^�[C�r¥��W�:��.�e���X!DGL;2�C���ʫ�i.f�A����8�%H�/�v�n�釄G�A��pP?,�}C?%<L߾�k1�8u��y��ti��	�s+�U�s�-��eM5�^x���(l�zŉ�a�l�����%���"����$�b���L�����P�ѡ���� t��\%�{d8َ
ߒ�[�P�mp����F?OD��%fw1w쑁�Ua-9k���AF!��}o�{�i�S�x��=��P���sƲeAs�J�r��Yn3U�D$�`�[ʃ��u��qG�����:����4��C᷄I�Si�M���#���K��A`0T�!{b��c&�hR���1��#�X��*_~�ZB	Ysd�	3Cka8����8�<��R�*^%��&��[���b�'���X�,��{O�H|A�����R狧�}���8��rd�����(�,+i6GA9MC:=�dF�
G)��d�Rh��Ҕ�2�ed��B��ȷ�;��Vp�%��%�D8̀,�K��(�ߞ�'���l 'pSC�}s+�w��s
W?�2���LZV�d�$��Z���J�9Y�3&Y2��BZV4|��L���� ���!�p�������< �oao,lӟ���J��J�*'/�ښ�X؏��md'�b�q�|��O�ߓ��]?�6����bIuQ��-�r[�+bO�\iP����I�X�����n_���s��R�*vJ����ײ�W����e�r��Rm7����bA���K��U��[�;���3E��f8� iϽ�n�eo�t5�#��WBYz>V�JkoE�(:Rq�9�O�#�~.����ɶ��Úǖl��:���#�������P��_�/���"����ɻPo�XȋRY���z"��}��I5����D^��ݬ��X�7�R�s�[��2�L�8Kr!;IǷֶU�ݖ��I\�-���4x7�F�^�M$�gu�ׅ2z�Tow�z� okb�_o���uW5��v�w�Q=��7��Pj�=t�I����<��/�g��#F�\�㹶x��\u�翓_�w�R�_�i}�� ?�)��\�yW}X�y�Gq�ź���aXW#�t�*��$tA��%�~��]���z�g�</��8�d��:�~X	o��58����"+��;_�)�H`0�H���z���p�a�q��8��G!�Gy��۪�"<ug�a��:|(9�8�t�k�cn�[�?ʎfV!��p�?P�+�?S�~��JQ$ͤR8�C#�7��A��#�VR��1~mC\�%1��� t�����l�ts^;���LzPū����|X֯����1�#+a�[�/o"�E�mg� ��t��P5��Aw�'�>�� �tۮw[�����};_��_�恆~a����X!�y��	�QS�9ܕ�!�Ã��j�*��ك}U:TS�� #�<��8L�*�̸����ًhQ#Ta<;x��� �h�$�	Ӝ�v�F+Z>�D��
�氛فZ�X�&��Ux8��xj�*�~�`}������M�����+f4�}gӥ���� �&��_2��/Mo�׳�?���^���f���3,B���Si����t��� \ʞ��9*�0W ����fNx�}Op`�9aX|s�?\\������?2�B��dP��Ql��� ����U��*��ձ�X�c�N#X+�p \���Q�z��mA&Ra������oI$�I�7���ܬ�cݾ��0� SpQH���@\�|��;�������ޕ���w���)UĎ�*=�j_�JQ��a1���pD���3��l=�k���;;;x����ya�~	�g(����U���Ӑ{8��'�m���e�E�}0%KrCͲ��:�b�ӶO '�V�`�Ȗ����ܹ�D$���ݍ�ޗQdeD4��B���YބeB�O�W"���ƙ��L�axC�`f�C�q�	��T=�,|��sx��5<���4&�4H��b>�֊��gD<�T�h�K��w.��E�q��eb�L��q���ҟ6j蕡H�m&��@Z�F�9W�x�1�T£����Ԁ��K�E�޲)���=\���ژ�_+��%�T|�E��%�7y�L��4���xǵmkc�gfY�+s�r�d��}_��旝����8��;�u#;�����~8
����37t�N�J;p=;��ߓ��ӓ�/=�ӣ�����E4>�G�,�P�BC�	TfКAfN������>ͥ�C��;��fy�VFЊ�O!�V9*��H|��[���� е�8:�ha޷t-����M�lqMU�]�P���Z�(��M�u�zC
�*Jh"P�3�t8��grd��_�q�_*]c�� ����쮊�\�;C-����d��>��߯�
��|�>����
��-�����C�>z?����}��2F���%�YC�
� ��������e��M�fk5��&�J.�aR�q�~��Uv���bj��#��XS�Ӧ��?ч��	�����ief�}�t��t�� �:J@�G�f��`0��`0��`0��7u�� 0 