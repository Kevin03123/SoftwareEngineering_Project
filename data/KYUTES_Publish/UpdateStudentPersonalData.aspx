<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateStudentPersonalData.aspx.cs" Inherits="KYUTES.UpdateStudentPersonalData" %>

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
            Init_DepartmentList();
            Init();
            SetListener();
        });

        function SetListener() {
            $('#btnUpdatePersonalData').click(function () {
                let flag = confirm('確定要更新嗎？');
                if (!flag) { return false; }

                UpdatePersonalData();
            });
        } // endSetListener

        function UpdatePersonalData() {
            let Name = $('#Name').val();
            let DepartmentId = $('#Department').val();
            let Pwd = $('#Pwd').val();

            let Method = 'UpdatePersonalData';
            let url = `/api/_UpdateStudentPersonalData.ashx?Method=${Method}`;
            let Parameters = { Name: Name, DepartmentId: DepartmentId, Pwd: Pwd };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('更新成功');
                location.reload()
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end UpdatePersonalData

        function Init_DepartmentList() {
            let Method = 'GetDepartmentList';
            let url = `/api/_UpdateStudentPersonalData.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#Department').append(`<option value='${val['id']}'>${val['DepartmentName']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }

        } // end Init_DepartmentList

        function Init() {
            let Method = 'GetStuData';
            let url = `/api/_UpdateStudentPersonalData.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                let data = result['Data'];
                $('#Name').val(data['Name']);
                $('#Department').val(data['DepartmentId']);
                $('#Pwd').val(data['Pwd']);
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }

        } // end Init

    </script>

</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>更新學生個人資料</h1>
                <hr />
            </div>

            <div class="LargeWord">
                <span>姓名 </span>
                <input id="Name" class="LargeWord" />
                <span>科系 </span>
                <select id="Department" class="LargeWord"></select>
                <br />
                <br />
                <span>登入密碼 </span>
                <input id="Pwd" class="LargeWord" />
                <br />
                <br />
                <input id="btnUpdatePersonalData" type="button" value="更新個人資料" class="LargeWord" />
            </div>



        </div>
    </form>
</body>
</html>
