+++
date = '2026-10-14T20:45:44+08:00'
draft = false
title = 'portswigger之jwt'
+++

个人觉得不错的文章：
https://www.cnblogs.com/sup3rman/p/16051163.html
https://blog.csdn.net/wahaha__zhou_/article/details/147429499

# jwt(json web token)

jwt格式:  header.payload.signature

其中header和payload部分都是base64编码的json对象，签名部分是二进制编码的

头部包含令牌本身的元数据，payload包含用户的实际“声明”

jwt签名：证明内容没有被篡改，可验证

```
签名 = 算法( 私钥, Base64Url(Header) + "." + Base64Url(Payload) 
```

| 概念 | 主要作用                                     | 你可以理解成         |
| ---- | -------------------------------------------- | -------------------- |
| JWT  | Token 的整体标准/形式                        | “令牌”               |
| JWS  | 对数据进行签名（算法(私钥，header+payload)） | “防篡改 + 验证身份”  |
| JWE  | 对数据进行加密（加密payload）                | “防止别人看到内容”   |
| JWK  | 描述密钥的 JSON 格式                         | “密钥的 JSON 身份证” |

| 字段  | 含义                   |
| ----- | ---------------------- |
| `kty` | Key Type，密钥类型     |
| `kid` | Key ID，密钥编号       |
| `use` | 密钥用途               |
| `alg` | 推荐/指定算法          |
| `n`   | RSA 公钥参数           |
| `e`   | RSA 公钥参数           |
| `x`   | EC/OKP 等密钥参数      |
| `d`   | 私钥参数，**非常敏感** |

header字段：

kid    密钥标识符，告诉服务器选择哪把密钥来进行验证jwt签名，这里就可能存在sql注入的手段，让服务器去查找密钥完成sql注入

alg    签名算法

### porswigger靶场

#### less1

服务器在使用jwt里面的sub做身份验证，但是没有验证签名是否与header+paylaod是否匹配，可以直接bp抓包登录后更改掉payload部分sub身份

可以看正常的jwt验证流程

Header.Paylaod-->签名算法(alg)-->header.paylaod.signature

#### less2

这一关还是服务器没有校验算法，直接更改就完成

#### less3（弱密钥爆破）

这一关很明显服务器验证了签名，像之前一样更改payload发包直接下线，

看alg算法是ha256，根据提示去尝试爆破私钥

hashcat工具爆破密钥，我当前专门为爆破弱jwt密钥的目录D:\tools\jwt-secrets-master

```
┌──(root㉿usually)-[/mnt/d/tools/hashcat]
└─# hashcat -a 0 -m 16500 'eyJraWQiOiJlNzAwN2YwMS02OTk0LTRjNDktODA2MC0yNzBiOWQwZjEyZDkiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTc5MTQ1MzQ5OSwic3ViIjoid2llbmVyIn0.wUF-n0lZ979Nzd5r-10RK-BDya_cMYXlU89gBtfCXFs' /mnt/d/tools/jwt-secrets-master/jwt.secrets.list
hashcat (v7.1.2) starting

OpenCL API (OpenCL 3.0 PoCL 7.1+debian  Linux, None+Asserts, RELOC, SPIR-V, LLVM 21.1.8, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
====================================================================================================================================================
* Device #01: cpu-haswell-13th Gen Intel(R) Core(TM) i7-13700HX, 1848/3697 MB (1848 MB allocatable), 24MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256
Minimum salt length supported by kernel: 0
Maximum salt length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1

Optimizers applied:
* Zero-Byte
* Not-Iterated
* Single-Hash
* Single-Salt

Watchdog: Temperature abort trigger set to 90c

Host memory allocated for this attack: 518 MB (6786 MB free)

Dictionary cache built:
* Filename..: /mnt/d/tools/jwt-secrets-master/jwt.secrets.list
* Passwords.: 103979
* Bytes.....: 1231757
* Keyspace..: 103965
* Runtime...: 0 secs

eyJraWQiOiJlNzAwN2YwMS02OTk0LTRjNDktODA2MC0yNzBiOWQwZjEyZDkiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTc5MTQ1MzQ5OSwic3ViIjoid2llbmVyIn0.wUF-n0lZ979Nzd5r-10RK-BDya_cMYXlU89gBtfCXFs:secret1

Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 16500 (JWT (JSON Web Token))
Hash.Target......: eyJraWQiOiJlNzAwN2YwMS02OTk0LTRjNDktODA2MC0yNzBiOWQ...tfCXFs
Time.Started.....: Thu Oct  8 17:13:11 2026 (1 sec)
Time.Estimated...: Thu Oct  8 17:13:12 2026 (0 secs)
Kernel.Feature...: Pure Kernel (password length 0-256 bytes)
Guess.Base.......: File (/mnt/d/tools/jwt-secrets-master/jwt.secrets.list)
Guess.Queue......: 1/1 (100.00%)
Speed.#01........:   405.0 kH/s (5.55ms) @ Accel:1024 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 24576/103965 (23.64%)
Rejected.........: 0/24576 (0.00%)
Restore.Point....: 0/103965 (0.00%)
Restore.Sub.#01..: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#01...:  -> 13451238317zhang
Hardware.Mon.#01.: Util:  4%

Started: Thu Oct  8 17:13:11 2026
Stopped: Thu Oct  8 17:13:13 2026
```

直接爆破出弱密钥出来:secret1

但是当前这个私钥完全不安全，所以在jwt.io这个网站更改的jwt是不合法的

#### less4(注入jwk头部绕过jwt认证)

这一关就是服务器端错误信任了header自己带的公钥进去，来验证自己本地私钥签名的jwt

因为我的bp是破解版的盗版，没有extention插件去下载jwt插件，然后我丢给agent，让他生成rsa私钥和公钥来生成一份签名的jwt，修改sub字段为administrator，并利用jwk注入改写公钥

```
header : {'kid': '247c9c30-...', 'alg': 'RS256', 'jwk': {...}}
payload: {'iss': 'portswigger', 'exp': 1791553158, 'sub': 'administrator'}
signature: VALID (verified against embedded jwk)
```

验证结果大概就是这样，完成jwk注入

#### less5(注入jku头部绕过jwt认证)

jku这个字段，告诉服务器去哪寻找公钥合集，

那这一关的思路大致就是本地生成一对公钥和私钥，更改jwt相关信息，用私钥完成签名，然后利用jku告诉服务器去相应地址利用公钥完成验证签名，从而绕过jwt认证

还是由于我的bp的jwt插件的缺陷问题，生成公钥和私钥完成签名验证的部分只能使用其他的工具替换，我这里使用python脚本完成    工具：生成rsa密钥  生成jwt set json格式

#### less6(kid参数路径穿越攻击)

漏洞形成原因：

服务器用 `kid` 去文件系统里找密钥文件，并且是**直接拼接路径**：

```java
String keyPath = "/keys/" + kid + ".pem";
byte[] keyBytes = Files.readAllBytes(Paths.get(keyPath));
```

正常请求：

```json
{ "alg": "HS256", "kid": "key-01" }
```

服务器读取：

```
/keys/key-01.pem
```

kid参数的值拼进文件路径参数，可以构造kid参数构成路径穿越



这一关的思路：抓到的jwt看到算法为hs256，对称密钥消息认证算法，当我们构造kid参数路径穿越指向一个空密钥的时候需要使用空密钥完成签名认证，需要在jwt.io网站上完成空密钥签名需要勾选base64编码完成

#### less7(算法混淆绕过jwt身份认证,暴露公钥)

这一关使用前面的应该都是不行的，根据提示观察这个是jwt算法混淆

**JWT 算法混淆 (Algorithm Confusion)**

- **技术原理**：利用 `alg` 头欺骗服务器，让服务器用**非对称公钥**（如 RSA 公钥）当作 **HMAC 密钥**来验证签名。
- **核心前提**：服务器**必须**配置了非对称算法（如 RS256），且**错误地信任了令牌头中的 `alg`**。
- **攻击结果**：使用**公开的 RSA 公钥**作为密钥，成功伪造一个 HS256 签名的令牌。

非对称密钥加密算法，私钥签名，公钥验证，这一关公钥暴露在/jwks.json，然后更改alg算法为对称加密hs256算法，使用暴露出来的公钥去完成签名就能让服务器使用这个公钥用对称加密算法错误的完成认证

需要注意的是

jwk转换成pem

算法混淆里,HS256 用的密钥是**公钥 PEM 的原始字节**(`-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----\n`,含结尾换行),**不是把 PEM 再 base64 一次的那个字符串**。

#### less8(jwt算法混淆无暴露公钥)

思路和第七关是一样的，唯一的区别就是没有暴露出公钥，但是可以根据两个账号去拿到两个jwt完成

**没有公钥怎么拿到公钥**

原理:单个 RSA 签名 `s = PKCS1v1.5(SHA256(header.payload))^d mod n`,于是 `s^e ≡ m (mod n)`,即 `n` 整除 `(s^e - m)`。**两个签名**各得一个这样的数,取它们的 **gcd** 就能解出 `n`(e 假设为 65537)。一个签名不够,所以才要两个。

```
二、数学原理:为什么"两个签名"能算出公钥
RSA 签名的本质:
- 先把 header.payload 做 SHA-256,再按 PKCS#1 v1.5 规则填充(EMSA),得到一个整数 m;
- 签名 s = m^d mod n(d 是私钥,n 是模数);
- 验签就是算 s^e mod n 看是否等于 m(e 是公钥指数)。
关键变形: 因为 s ≡ m^d (mod n),两边同取 e 次方得
s^e ≡ (m^d)^e = m^(de) ≡ m   (mod n)
移项:
s^e - m ≡ 0   (mod n)   ⇒   n 整除 (s^e - m)
也就是说,每个 token 都能构造出一个"n 的倍数"。但单个 s^e - m 是个天文数字,你没法直接摘出 n。
两个 token 就够了: 你有两个都是同一把私钥签的 token,于是
n | (s1^e - m1)   且   n | (s2^e - m2)
两个数都被 n 整除,那么 n 也整除它们的最大公约数:
n = gcd( s1^e - m1 ,  s2^e - m2 )      (可能还要除掉一个小因子)
这就是 rsa_sign2n / sig2n 的全部秘密 —— 一个 gcd 就还原了模数 n。
两个现实约束,解释了你为什么会看到"多个候选 key":
1. e 未知 → 工具假设 e = 65537(即 JWK 里的 "e":"AQAB",99.9% 是它)。
2. 模数长度 emlen 未知 → 填充要凑到"密钥字节长度"那么长,可你不知道密钥是 2048/3072/4096 位。工具会把几种可能长度都试一遍。
3. 而且 gcd 出来的可能是 n 也可能是 n 的小倍数,所以会吐出一个到几个候选 n,每个都对应一把候选公钥,需要你逐个试。
三、你的脚本原理:它其实是个"外壳"
你的 Python 脚本本体没有任何密码学逻辑,它只做一件事:把 token 拼到命令行,调 Docker:
subprocess.run(['docker','run','--rm','-it','portswigger/sig2n', token1, token2], ...)
真正的 gcd 计算在 portswigger/sig2n 这个镜像里(就是 silentsignal 的 rsa_sign2n)。所以:
- 脚本 = 参数拼装 + 调 docker + 打印输出;
- 想换题,只要改 token1/token2;
- 它跑得慢/失败,问题都在 docker 那一层,不在 Python。
两个小提醒(和原理无关,是用法):
- -it 里的 -t 会申请一个 TTY;你用 subprocess.run(capture_output=True) 没有终端,-t 有时会报 the input device is not a TTY。建议去掉 -t,只留 --rm;
- 顺手把 result.stderr 也打印出来,方便看错误。
四、sig2n 的输出,以及"Base64 encoded x509 key"是什么
工具大概会打印:
n = <一堆十六进制>
Base64 encoded x509 key:  LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0K......
Base64 encoded pkcs1 key: ......
JWT using x509 key:       <一把已经签好的篡改 token>
JWT using pkcs1 key:      ...
- X.509 格式 = 带 -----BEGIN PUBLIC KEY----- 头的 SubjectPublicKeyInfo PEM(第七关 /jwks.json 转出来的就是这种);
- 那串 Base64 encoded x509 key,就是把整段 PEM(含头尾和换行)再做一次 base64。你一解 LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0K 就知道它是 -----BEGIN PUBLIC KEY-----\n。
- 所以"拿它当签名密钥"的真正含义是:它解码回来 = 公钥 PEM 原文 = HS256 的 HMAC 密钥。
在工具里的落地方式(和第七关一模一样):
- Burp JWT Editor:New Symmetric Key,把 k 填成"这段 base64 转成 base64url 后"的值(即把 +→-、/→_、去掉 =),因为 k 是 base64url。这样一把对称密钥的原始字节就等于公钥 PEM。
- 或者更省事:直接复制它给你的 JWT using x509 key 那把现成 token,替换 session cookie 打 /admin,再 /admin/delete?username=carlos。
一句话串起来:alg 改 HS256 → 用两个 token 的 gcd(s^e - m) 还原 n → 拼成公钥 PEM → 用 PEM 原文当 HMAC 密钥签一个 admin token → 过关。你脚本负责的只是"喂 token 给 sig2n",真正的数学在"gcd 反推 n"这一步。
```

## jwt防御策略

````
● JWT 防御策略

  核心原则：签名只保证"没被篡改"和"是我签的"，不保证"内容没被看过"、也不保证"算法是我选的那个"。 防御要围绕这两点展开。

  1. 算法相关（最高频的坑）

  禁止客户端指定算法
  - 服务端硬编码 algorithms=["RS256"]，绝不用 header 里的 alg 去动态选算法。
  - 防 alg: none：校验时显式拒绝 none（很多库默认就拒，但别赌）。
  - 防 HS256/RS256 混淆攻击：RS256 的公钥如果被拿去当 HMAC
  密钥验证，攻击者就能用公钥伪造。要求签名算法与密钥类型严格匹配，公钥/私钥分开存储，别复用同一份密钥材料。

  验证内容必须包含签名
  - 用封装好的 jwt.verify() 类接口，别自己 decode(token, verify=False) 只取 payload 就完事。

  2. 密钥强度

  - HS256：密钥必须是足够长的随机值（≥256 bit），别用 secret、your-256-bit-secret 这类。弱密钥可被 hashcat 快速爆破。
  - 生产环境优先 RS256 / ES256（非对称），私钥不出签发服务，验签方只持公钥。

  3. Header 参数注入

  - kid：攻击者塞路径穿越（../../dev/null）或 SQL 注入，诱导服务端加载错误密钥。白名单化 kid，绝不拿它直接拼路径/查库。
  - jwk / jku / x5u：让服务端去取攻击者控制的公钥。直接忽略这些 header，密钥永远从服务端自己的 key set 里取。

  4. 声明（claim）校验

  必须逐项验证，缺一不可：
  - exp / nbf / iat：过期和生效时间，注意时钟偏移容忍要小。
  - iss：签发方是否可信。
  - aud：受众是否是本服务（防跨服务重放）。
  - sub / 自定义声明：按业务校验。

  5. 失效与撤销

  JWT 无状态、签发后默认无法撤回，所以：
  - 短有效期（access token 15min~1h）+ refresh token 续期。
  - 需要强撤销（登出、改密、封号）时维护黑名单/jti 表，或在服务端存 session 状态。
  - 高敏感操作（改密、转账）要求重新认证，光有 token 不够。

  6. 存储与传输

  - 别放 localStorage（XSS 直接偷）→ 用 HttpOnly + Secure + SameSite Cookie，此时补 CSRF 防护；或存内存 + 配合 refresh。
  - 强制 HTTPS。
  - payload 只是 base64，不是加密。别塞密码、身份证、手机号等敏感数据；确需加密用 JWE。

  7. 其他

  - 限制 token 大小、并发校验、给签名验证加超时（防算法升级到超长 key 的 DoS）。
  - 校验前先验签，再解析业务逻辑，别把未验签的 payload 用于任何判断。

  ---
  一句话记忆：算法钉死、密钥够强、header 不信任、claim 全验、能撤销、别存敏感信息
````




