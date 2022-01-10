<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrepareExams.aspx.cs" Inherits="KYUTES.PrepareExams" %>

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

            /* 要加這一行，各欄位得搜尋輸入框才會跑到table的頂部 */
            .display tfoot {
                display: table-header-group;
            }

        /*----------------------------------------*/
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>

        function SetListener() {
            $("#PrepareExamsList > tbody").on('click', "input[type='button']", function () {
                let ExamId = $(this).attr("examid");
                let tr = $(this).closest('tr');
                let QuestionBankName = $(tr).find('td').eq(3).text();

                let flag = confirm(`確定要前往測驗 ${ExamId} | ${QuestionBankName} ？`);
                if (!flag) { return false; }

                let url = `ActualExam.aspx?ExamId=${ExamId}`;
                window.open(url);
            });
        } // end SetListener

        $(document).ready(function () {
            Init_PrepareExamsList();
            SetListener();
        });

        // 建立 DataTable 標頭跟標尾
        function CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });
            headerList.unshift('選取'); // 從list前端加入元素

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
                if (item == '選取') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `<input type="button" value="前往測驗" style='font-size:large;' examid="${row['測驗編號']}" />`;
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

        function Init_PrepareExamsList() {
            let Method = 'GetPrepareExamsList';
            let url = `/api/_PrepareExams.ashx?Method=${Method}`;
            let response = CallAPI(url);

            let isSuccess = response['isSuccess'];
            if (!isSuccess) {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                    return false;
                }
            }

            let result = response['Data'];

            if (result == [] || result.length == 0) {
                alert('無資料');
                return false;
            } else {
                let headerList = CreateHeaderAndFooter('#PrepareExamsList', result[0]);
                var DataTableColumns = CreateDataTableColumns(headerList);
            }

            $.each(result, function (i, v) { v['教師建立測驗時間'] = v['教師建立測驗時間'].replace('T', ' '); });

            let MyTable = $('#PrepareExamsList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                //order: [[1, "desc"]],
                data: result,
                columns: DataTableColumns,
            }); // end $('#ExamList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#PrepareExamsList tfoot th').each(function () {
                let title = $(this).text();
                if (title == '選取') {
                    //$(this).html(`<input disabled='disabled' style='width:100%;'/>`);
                    $(this).html(``);
                } else {
                    $(this).html(`<input type='text' style='width:100%;' placeholder='Search...'/>`);
                }
            });

            // Apply the search
            MyTable.columns().every(function () {
                let that = this;

                $('input', this.footer()).on('keyup change', function () {
                    if (that.search() !== this.value) {
                        that.search(this.value).draw();
                    }

                    // 依據輸入的值，動態改變搜尋輸入框的寬度
                    // 參考網址 http://jsfiddle.net/nrabinowitz/NvynC/
                    $(this).attr('size', $(this).val().length);
                });
            });

        } // end Init_PrepareExamsList

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h1>待測驗列表</h1>
            <hr />
        </div>

        <div>
            <table id="PrepareExamsList" class="display" style="width: 100%"></table>
        </div>
    </form>
</body>
</html>
