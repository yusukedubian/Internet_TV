function loadFeed() {
    // 初期化
    var feed = new google.feeds.Feed("http://4travel.jp/rdf/travelogue_all_new.xml");
    // 記事を最大10件読み込む
    feed.setNumEntries(10);
    // 記事を読み込む
    feed.load(function(result) {
        var html;
        // 読み込みに成功したときの処理
        if (!result.error) {
            // サイトのタイトルを出力
            html = '<h1><a href="' + result.feed.link + '">' + result.feed.title + '</a></h1>';
            // 各記事の情報を順に出力
            if (result.feed.entries.length) {
                html += '<ul>';
                for (var i = 0; i < result.feed.entries.length; i++) {
                    // 各記事のタイトルと概要を出力
                    var entry = result.feed.entries[i];
                    html += '<li><a href="' + entry.link + '">' + entry.title + '</a><br />';
                    html += '<span class="content">' + entry.contentSnippet + '</span></li>';
                }
                html += '</ul>';
           }
       }
       // 読み込みエラー時の処理
       else {
           html = '<p>フィードの読み込みに失敗しました。</p>';
       }
       // 読み込み結果を、idが「feed」の要素に流し込む
       var container = document.getElementById("rurubutxt");
       container.innerHTML = html;
    });
}
