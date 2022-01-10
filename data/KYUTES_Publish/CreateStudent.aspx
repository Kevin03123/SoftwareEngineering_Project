<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateStudent.aspx.cs" Inherits="KYUTES.CreateStudent" %>

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
            Init();
            Listener();
        });

        function Listener() {
            $('#btnCreate').click(function () {

                let flag = confirm('確定要新增嗎？');
                if (!flag) { return false; }

                let Acct = $('#Acct').val();
                let Pwd = $('#Pwd').val();
                let Name = $('#Name').val();
                let Department = $('#Department').val();

                AddStudent(Acct, Pwd, Name, Department);
            });
        } // end Listener

        function Init() {
            InitSubjectInfos();
        }

        function InitSubjectInfos() {
            let Method = 'GetSubjectInfos';
            let url = `/api/_CreateStudent.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#Department').empty();

                let data = result['Data']
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

        } // end GetSubjectInfos

        function AddStudent(Acct, Pwd, Name, Department) {
            let Method = 'AddStudent';
            let url = `/api/_CreateStudent.ashx?Method=${Method}`;
            let Parameters = { Acct: Acct, Pwd: Pwd, Name: Name, Department: Department };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('新增成功');
                window.open("ViewStudentList.aspx");
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end AddStudent


    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div style="text-align: center;">
            <h1>新增學生</h1>
            <hr />
            <br />
        </div>

        <div class="LargeWord" style="text-align: center;">
            <span>帳號 </span>
            <input id="Acct" class="LargeWord" />
            <br />
            <br />

            <span>密碼 </span>
            <input id="Pwd" class="LargeWord" />
            <br />
            <br />

            <span>姓名 </span>
            <input id="Name" class="LargeWord" />
            <br />
            <br />

            <span>科系 </span>
            <select id="Department" class="LargeWord"></select>
            <br />
            <br />

            <br />
            <input id="btnCreate" type="button" value="新增" class="LargeWord" style="width: 300px;" />
        </div>
    </form>
</body>
</html>
