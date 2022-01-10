// 呼叫API
function CallAPI(url, Parameters = null, RequestMethod = 'POST') {
    let result = null;

    $.ajax({
        url: url,
        type: RequestMethod,
        data: Parameters,
        async: false // 要用同步,不然有可能資料尚未載入,就先 return (還是null) 回去了
    }).done(function (response) {
        result = response;
    }).fail(function (res, status, errorMsg) {
        result = null;
        alert(errorMsg);
    }).always(function () {

    });

    return result;
} // end CallAPI

function GoToDefaultPage() {
    location.href = 'index.aspx';
}

function CloseWindow() { // 關閉視窗
    window.location.href = "about:blank";
    window.close();
} // end CloseWindow

(() => { // 立即函式 CreateMasterPage
    $(document).ready(function () {
        let url = new URL(window.location.href);
        let pageName = url.pathname.substr(1);
        let Parameters = { pageName: pageName };
        let apiUrl = `/api/CreateMasterPage.ashx`;

        let result = CallAPI(apiUrl, Parameters);
        if (result.length == 0) { return false; }
        let items = result;

        let Split_bottom = `<div style="clear: both; border-bottom: solid; margin-left: -10px; margin-right: -10px; margin-bottom: 15px;"></div>`;

        let masterPage = '';
        $.each(items, function (idx, item) { masterPage += `<a href="${item['url']}">${item['text']}</a>`; });

        masterPage = `<div class="masterPage">${masterPage}</div>`;
        masterPage = `${masterPage}${Split_bottom}`;

        $('body').prepend(masterPage);
        $('head').prepend(`<link href="Css/masterPage.css" rel="stylesheet" />`);
    });

    /*
    <div class="masterPage">
        <a href="PrepareExams.aspx" target="_blank">待測驗列表</a>
        <a href="ViewExamScore.aspx" target="_blank">檢視測驗成績</a>
        <a href="UpdateStudentPersonalData.aspx" target="_blank">更新學生個人資料</a>
        <a href="Logout.aspx" target="_blank">登出</a>
    </div>
    <div style="clear: both; border-bottom: solid; margin-left: -10px; margin-right: -10px; margin-bottom: 15px;"></div>
     */
})();