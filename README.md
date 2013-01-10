google_calendar_util
====================

Googleカレンダーのイベント一覧を取得してCSVファイルに書き出すスクリプトです。

認証を行い`.google-api.yaml`を上書きしてください。

    % bundle exec google-api oauth-2-login --scope=https://www.googleapis.com/auth/calendar --client-id=CLIENT_ID --client-secret=CLIENT_SECRET
    % cp ~/.google-api.yaml path/to/project/

実行方法

    % ruby app.rb [-c num] [month] [year]

取得したイベントデータをCSV形式で標準出力へ表示します．
