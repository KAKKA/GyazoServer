GyazoServer
===========

gyazoのプライベートなサーバー

準備

rbenvとbundler

環境
さくらVPS CentOS 6.5
rbenv
bundler
ruby 1.8.7以上
nginx

リポジトリ
https://github.com/KAKKA/GyazoServer/

gyazoserverの設定

    $ cd /opt/
    $ mkdir /opt/gyazo
    $ git clone git@github.com:KAKKA/GyazoServer.git gyazoserver
    
gyazoserver/gyazo.rbの最終行を自分のサーバーのドメインに設定しておく。
    L34     "http://hoge.com/#{hash}.png"
    
nginxの設定

    # nginxのリポジトリを追加
    $ vim /etc/yum.repos.d/nginx.repo

    [nginx]
    name=nginx repo
    baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
    gpgcheck=0
    enabled=1

    # nginxのインストール
    $ yum install nginx
    
    # nginxの設定ファイル編集

    $ vi /etc/nginx/nginx.conf

    worker_processes  2;

    events {
        worker_connections  1024;
    }

    http {
        include       mime.types;
        default_type  application/octet-stream;

        # nginxのサーバーバージョンを返さない設定
        server_tokens    off;

    # logformatにLTSVをセット
    log_format  ltsv  'time:$time_local\t'
                      'msec:$msec\t'
                      'host:$remote_addr\t'
                      'forwardedfor:$http_x_forwarded_for\t'
                      'req:$request\t'
                      'method:$request_method\t'
                      'uri:$request_uri\t'
                      'status:$status\t'
                      'size:$body_bytes_sent\t'
                      'referer:$http_referer\t'
                      'ua:$http_user_agent\t'
                      'reqtime:$request_time\t'
                      'upsttime:$upstream_response_time\t'
                      'cache:$upstream_http_x_cache\t'
                      'runtime:$upstream_http_x_runtime\t'
                      'vhost:$host';

    sendfile        on;

    sendfile        on;

    # keepaliveを60秒に
    keepalive_timeout  60;

    # gzipを有効
    gzip  on;

    # proxy cacheを有効に
    # key 32MB/max 300MB/最大有効期限7日
    proxy_cache_path /var/cache/nginx/cache levels=1:2 keys_zone=my-key:32m max_size=300m inactive=7d;
    proxy_temp_path /var/cache/nginx/tmp;

    # conf.d配下を読み込むようにセット
    include /etc/nginx/conf.d/*.conf;
    }
    
    # nginxへgyazoサーバーの設定

    $ vi /etc/nginx/conf.d/gyazo.conf

    upstream gyazo {
        server 49.212.213.57:8000;
    }

    server {
        listen       80;
        server_name  49.212.213.57;

        charset UTF-8;
        charset_types text/css text/plain;

        #gyazoれる画像サイズの最大MBを指定
        client_max_body_size 30M;

        #gyazo中のタイムアウトを5分で設定
        send_timeout            300;
        proxy_connect_timeout   300;
        proxy_send_timeout      300;
        proxy_read_timeout      300;

        #アクセスログの吐き出しを設定
        access_log /var/log/nginx/gya_access.log ltsv;
        error_log /var/log/nginx/gya_error.log;

        #ドキュメントルートを設定
        root /opt/gyazo;

        #ドキュメントルートにキャッシュを設定
        # ヘッダのキャッシュコントロール無視、200レスポンスは最大3日キャッシュ404キャッシュは10分
        location / {
            proxy_ignore_headers Cache-Control;
            proxy_cache_valid 200 3d;
            proxy_cache_valid 404 10m;
        }

        location /upload {
            proxy_pass http://gyazo;
            break;
        }
    }
    
    # nginxのスタート
    $ /etc/init.d/nginx start
    
    
    
    
Macの場合

Gyazo.appを本家から入手して、terminal.appからいじる。

    vim /Applications/Gyazo.app/Contents/Resources/script

     50 HOST = '49.212.213.57'
     51 CGI = '/upload'
     52 UA   = 'Gyazo/2.0'

Windowsの場合

gyazwinを使って、iniファイルにhost/cgi先を同様にセットすればOK
gyazowin+を最新のgyazowinのソースとマージした - tyoro.exe
http://exe.tyo.ro/2012/02/gyazowingyazowin.html

Androidの場合

URLを指定できる
GyazoAndroid - Google Play の Android アプリ
https://play.google.com/store/apps/details?id=jp.backspace.app.android.gyazo&hl=ja
