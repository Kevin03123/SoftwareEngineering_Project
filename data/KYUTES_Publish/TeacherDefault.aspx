<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherDefault.aspx.cs" Inherits="KYUTES.TeacherDefault" %>

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
                <h1>Welcome 教師 !</h1>
                <hr />
            </div>

            <div>
                <div class="items">
                    <ol>
                        <li><a href="CreateStudent.aspx" target="_blank">新增學生</a></li>
                        <li><a href="ViewStudentList.aspx" target="_blank">檢視 / 管理 學生列表</a></li>
                        <li><a href="SubjectManagement.aspx" target="_blank">科目管理</a></li>
                        <li><a href="QuestionManagement.aspx" target="_blank">題目管理</a></li>
                        <li><a href="QuestionBankManagement.aspx" target="_blank">題庫管理</a></li>
                        <li><a href="ExamGroupManagement.aspx" target="_blank">測驗管理</a></li>
                        <li><a href="TeacherViewStudentExamScore.aspx" target="_blank">檢視學生測驗成績</a></li>
                    </ol>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
