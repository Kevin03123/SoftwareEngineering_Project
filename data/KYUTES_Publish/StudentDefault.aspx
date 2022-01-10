<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDefault.aspx.cs" Inherits="KYUTES.StudentDefault" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <style>
        ol li:hover {
            background: #d7d7db;
            cursor: pointer;
        }

        ol li a {
            color: black;
            text-decoration: none;
        }

        .items {
            font-size: x-large;
        }
    </style>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="Scripts/Common.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>Welcome 學生 !</h1>
                <hr />
            </div>

            <div>
                <div class="items">
                    <ol>
                        <li><a href="PrepareExams.aspx" target="_blank">待測驗列表</a></li>
                        <li><a href="ViewExamScore.aspx" target="_blank">檢視測驗成績</a></li>
                        <li><a href="UpdateStudentPersonalData.aspx" target="_blank">更新學生個人資料</a></li>
                    </ol>
                </div>
            </div>
        </div>

    </form>
</body>
</html>
