<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActualExam.aspx.cs" Inherits="KYUTES.ActualExam" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <style>
        .display {
            text-align: center;
            font-size: larger;
        }
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>

        var ExamId = -1;
        var timer = null;

        $(document).ready(function () {
            CheckUrl();
            Init_ExamSummary();
            Init_QuestionList();
            Init_ExamBlock();
            SetListener();
        });

        function Init_ExamBlock() {
            $('#ExamBlock').hide();
        }

        function SetListener() {
            $('#btnSubminExam').click(function () {
                let flag = confirm(`確定要交卷了 ？`);
                if (!flag) { return false; }

                KillTimer();
                SubminExam();
            });

            $('#btnStartExam').click(function () {
                let flag = confirm(`開始測驗後系統將會啟動倒數計時，時間結束時系統會自動提交試卷\n測驗途中不可重新整理或關閉此頁面\n確定要開始測驗 ？`);
                if (!flag) { return false; }

                $(this).hide();
                $('#ExamBlock').show();

                StartTimer();
            });
        } // end SetListener

        function StartTimer() {
            let RemainTime = parseInt($('#TestTime').text()) * 60;
            timer = window.setInterval(function () {
                let timerMsg = new Date(RemainTime * 1000).toISOString().substr(14, 5) // 剩餘當下時間 MM:SS
                $('#RemainTime').text(timerMsg);

                if (RemainTime == -1) { // 倒數計時結束
                    alert('時間到 !');
                    KillTimer() // 消滅 timer
                    $('#RemainTime').text('00:00');
                    SubminExam(); // 交卷
                }

                RemainTime -= 1;
            }, 1000);
        } // end StartTimer

        function KillTimer() {
            clearInterval(timer); // 消滅 timer
        } // end KillTimer

        function SubminExam() {
            let selectOptions = $("#QuestionList tbody select");
            let Pairs = $.map(selectOptions, function (x) {
                let tr = $(x).closest('tr');
                let QId = $(tr).find('td').eq(0).text();
                let value = $(x).val();

                return { 'QId': QId, 'UserAns': value };
            });

            let Method = 'SubminExam';
            let url = `/api/_ActualExam.ashx?Method=${Method}`;
            let Parameters = { ExamId: ExamId, Pairs: JSON.stringify(Pairs) };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('提交成功');
                location.href = 'ViewExamScore.aspx';
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end SubminExam

        // 建立 DataTable 標頭跟標尾
        function CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });
            headerList.push('作答'); // 從lis後端加入元素

            //-----------------------------------------------------------------

            // 將標頭欄位list綁訂到htmltable的thead
            $(`${tableId}`).append('<thead></thead>');
            $(`${tableId} > thead`).append('<tr></tr>');
            $.each(headerList, function (i, v) {
                $(`${tableId} > thead > tr`).append(`<th>${v}</th>`);
            });

            //-----------------------------------------------------------------

            // 將標頭欄位list綁訂到htmltable的tfoot
            $(`${tableId}`).append('<tfoot></tfoot>');
            $(`${tableId} > tfoot`).append('<tr></tr>');
            $.each(headerList, function (i, v) {
                $(`${tableId} > tfoot > tr`).append(`<th>${v}</th>`);
            });

            //-----------------------------------------------------------------

            return headerList;
        } // end CreateHeader

        // 建立 DataTable 欄位屬性
        function CreateDataTableColumns(headerList) {
            let DataTableColumns = $.map(headerList, function (item, index) {
                if (item == '作答') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `
                            <select>
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                            `;
                            return data;
                        }
                    };
                } else {
                    item = { "data": item };
                }

                return item;
            });

            return DataTableColumns;
        } // end CreateDataTableColumns

        function Init_QuestionList() {
            let Method = 'GetQuestionList';
            let apiurl = `/api/_ActualExam.ashx?Method=${Method}`;
            let Parameters = { ExamId: ExamId };

            let response = CallAPI(apiurl, Parameters);
            let isSuccess = response['isSuccess'];
            let Msg = response['Msg'];

            if (!isSuccess) {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                    CloseWindow();
                }
            }

            //---------------------------------------------------

            let result = response['Data'];

            if (result == [] || result.length == 0) {
                alert('無資料');
                return false;
            } else {
                let headerList = CreateHeaderAndFooter('#QuestionList', result[0]);
                var DataTableColumns = CreateDataTableColumns(headerList);
            }

            let MyTable = $('#QuestionList').DataTable({
                lengthMenu: [
                    [100],    // 實際值
                    [100]     // 顯示用
                ],
                pageLength: 100,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                //order: [[0, "desc"]],
                data: result,
                columns: DataTableColumns,
            }); // end $('#DataList').DataTable

        } // end Init_QuestionList

        function CheckUrl() {
            let url = new URL(window.location.href);
            if (!url.searchParams.has('ExamId')) { GoToDefaultPage(); }

            ExamId = url.searchParams.get("ExamId");
            if (ExamId == '') { GoToDefaultPage(); }
        }

        function Init_ExamSummary() {
            ExamId = new URL(window.location.href).searchParams.get("ExamId");

            let Method = 'GetExamSummary';
            let apiurl = `/api/_ActualExam.ashx?Method=${Method}`;
            let Parameters = { ExamId: ExamId };

            let result = CallAPI(apiurl, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (!isSuccess) {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                    CloseWindow();
                }
            }

            //---------------------------------------------------

            let ExamSummary = result['Data'][0];

            $('#ExamId').text(ExamSummary['測驗編號']);
            $('#QBId').text(ExamSummary['題庫編號']);
            $('#QuestionBankName').text(ExamSummary['題庫名稱']);
            $('#SubjectName').text(ExamSummary['科目名稱']);
            $('#Level').text(ExamSummary['測驗難度']);
            $('#ExamType').text(ExamSummary['測驗類型']);
            $('#TestTime').text(ExamSummary['測驗總時間']);
            $('#QuestionCount').text(ExamSummary['測驗總題數']);
            $('#CreateTime').text(ExamSummary['教師建立測驗時間'].replace('T', ' '));
        } // end Init_Summary

    </script>

</head>

<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>實際測驗</h1>
                <hr />
            </div>

            <div>
                <h2>
                    <span>測驗編號: </span><span id="ExamId"></span>&nbsp;&nbsp;&nbsp;
                    <span>題庫編號: </span><span id="QBId"></span>&nbsp;&nbsp;&nbsp;
                    <span>題庫名稱: </span><span id="QuestionBankName"></span>&nbsp;&nbsp;&nbsp;
                    <span>科目名稱: </span><span id="SubjectName"></span>&nbsp;&nbsp;&nbsp;
                    <span>測驗難度: </span><span id="Level"></span>
                    <br />
                    <span>測驗類型: </span><span id="ExamType"></span>&nbsp;&nbsp;&nbsp;
                    <span>測驗總時間: </span><span id="TestTime"></span>&nbsp;&nbsp;&nbsp;
                    <span>測驗總題數: </span><span id="QuestionCount"></span>&nbsp;&nbsp;&nbsp;
                    <span>教師建立測驗時間: </span><span id="CreateTime"></span>
                </h2>
                <hr />

                <div>
                    <h2>
                        <input id="btnStartExam" type="button" value="開始測驗" style="font-size: x-large; width: 300px;" /></h2>
                </div>

                <div id="ExamBlock">
                    <h2><span>剩餘時間: </span><span id="RemainTime"></span></h2>
                    <br />

                    <table id="QuestionList" class="display" style="width: 100%"></table>
                    <br />
                    <input id="btnSubminExam" type="button" value="交卷" style="font-size: x-large; width: 300px;" />
                </div>
            </div>

        </div>
    </form>
</body>

</html>
