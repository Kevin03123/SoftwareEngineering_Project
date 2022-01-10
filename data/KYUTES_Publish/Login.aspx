<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="KYUTES.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <style>
        .LargeWord {
            font-size: x-large;
        }
    </style>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>
        $(document).ready(function () {
            Listener();
        });

        function Listener() {
            $('#Pwd,#Acct').keyup(function (e) {
                if (e.keyCode == 13) { // 放開enter鍵
                    LoginCheck();
                }
            })

            $('#btnCheck').click(function () {
                LoginCheck();
            });
        } // end Listener

        function LoginCheck() {

            let UserType = $('#UserType').val();
            let Acct = $('#Acct').val();
            let Pwd = $('#Pwd').val();

            let Method = 'LoginCheck';
            let url = `/api/_Login.ashx?Method=${Method}`;
            let Parameters = { Acct: Acct, Pwd: Pwd, UserType: UserType };

            let result = CallAPI(url, Parameters);

            let isSuccess = result['isSuccess'];
            if (!isSuccess) {
                alert('帳密錯誤');
                return false;
            } else {
                alert('登入成功');
                location.href = result['Data'];
            }
        } // end LoginCheck


    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="LargeWord">
            <span>身分 </span>
            <select id="UserType" class="LargeWord">
                <option value="1">老師</option>
                <option value="2">學生</option>
            </select>
            <br />
            <br />

            <span>帳號 </span>
            <input id="Acct" class="LargeWord" /><br />
            <br />

            <span>密碼 </span>
            <input id="Pwd" class="LargeWord" /><br />

            <hr />

            <input id="btnCheck" type="button" value="確認" class="LargeWord" />
        </div>

    </form>
</body>
</html>
