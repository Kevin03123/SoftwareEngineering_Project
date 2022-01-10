<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExamGroupManagement.aspx.cs" Inherits="KYUTES.ExamGroupManagement" %>

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

        .mainDiv ul li a {
            color: black;
            text-decoration: none;
        }

        .mainDiv {
            padding-right: 5px;
            background: #FFF;
            padding: 20px;
            font-weight: bold;
        }

        .expandableCollapsibleDiv img {
            cursor: pointer;
            margin-right: 10px;
            margin-top: 15px;
            padding-left: 10px;
            float: left;
        }

        .expandableCollapsibleDiv > span:hover {
            background: #d7d7db;
            background-color: rgb(217, 237, 247);
        }

        .expandableCollapsibleDiv > span {
            cursor: pointer;
            font-size: xx-large;
        }

        .expandableCollapsibleDiv ul {
            border-bottom: 1px solid #000;
            clear: both;
            list-style: outside none none;
            margin: 0;
            padding-bottom: 10px;
            display: none;
            padding-left: 25px;
        }

        /*----------------------------------------*/
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>

        let SelectedQuestionBankId = -1;
        let SelectedStudentIds = [];

        function SetListener() {
            $("#QuestionBankList > tbody").on('click', "input[type='button']", function () {
                let QBId = $(this).attr("qbid");
                let tr = $(this).closest('tr');
                let QuestionBankName = $(tr).find('td').eq(2).text();

                SelectedQuestionBankId = QBId;

                let Msg = `題庫編號: ${QBId} | 題庫名稱: ${QuestionBankName}`;
                $('#SelectedQuestionMsg').html(Msg);
            });

            $("#StuList > tbody").on('change', "input[type='checkbox']", function () {
                ComputeSelectedStus();
            });

            $('#btnCreate').click(function () {
                let flag = confirm(`確定要新增本次測驗嗎？`);
                if (!flag) { return false; }

                CreateExam();
            });

            $('.expandableCollapsibleDiv > span').click(function (e) {
                OpenOrClose(this);
            });
        } // end SetListener

        function OpenOrClose(tag) {
            let showElementDescription = $(tag).parents('.expandableCollapsibleDiv').find('ul');
            let img = $(tag).children('img');

            if ($(showElementDescription).is(':visible')) {
                showElementDescription.hide("fast", "swing");
                $(img).attr("src", "images/up-arrow.jpg");
            } else {
                showElementDescription.show("fast", "swing");
                $(img).attr("src", "images/down-arrow.jpg");
            }
        } // end OpenOrClose

        function CreateExam() {
            let ExamType = $('#ExamType').val();

            let Method = 'CreateExam';
            let url = `/api/_ExamGroupManagement.ashx?Method=${Method}`;
            let Parameters = { ExamTypeId: ExamType, QBId: SelectedQuestionBankId, StuIds: SelectedStudentIds.join() };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('新增成功');
                location.reload();
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end CreateExam

        function ComputeSelectedStus() {
            let selectckbxs = $("#StuList tbody input:checkbox:checked");
            SelectedStudentIds = $.map(selectckbxs, function (x) { return $(x).val(); });

            let str = '';
            $.each(selectckbxs, function (i, x) {
                let tr = $(x).closest('tr');

                let SId = $(tr).find('td').eq(1).text();
                let StuName = $(tr).find('td').eq(3).text();
                let Subject = $(tr).find('td').eq(4).text();

                str += `學生編號: ${SId} | 姓名: ${StuName} | 科系: ${Subject}<br/>`;
            });

            $('#SelectedStuMsg').html(str);
        } // end ComputeSelectedStus

        function Init_ExamType() {
            let Method = 'GetExamTypeList';
            let url = `/api/_ExamGroupManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#ExamType').empty();

                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#ExamType').append(`<option value='${val['id']}'>${val['Descript']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_ExamType

        $(document).ready(function () {
            Init_ExamList();
            Init_ExamType();
            Init_QuestionBankList();
            Init_StuList();
            SetListener();
        });

        // 建立 DataTable 標頭跟標尾
        function ExamList_CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });

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
        function ExamList_CreateDataTableColumns(headerList) {
            let DataTableColumns = $.map(headerList, function (item, index) {
                item = { "data": item };
                return item;
            });

            return DataTableColumns;
        } // end CreateDataTableColumns

        function Init_ExamList() {
            let Method = 'GetExamList';
            let url = `/api/_ExamGroupManagement.ashx?Method=${Method}`;
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
                let headerList = ExamList_CreateHeaderAndFooter('#ExamList', result[0]);
                var DataTableColumns = ExamList_CreateDataTableColumns(headerList);
            }

            $.each(result, function (i, v) { v['建立時間'] = v['建立時間'].replace('T', ' '); });

            let MyTable = $('#ExamList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                order: [[1, "desc"]],
                data: result,
                columns: DataTableColumns,
            }); // end $('#ExamList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#ExamList tfoot th').each(function () {
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

        } // end Init_ExamList

        // 建立 DataTable 標頭跟標尾
        function QuestionBankList_CreateHeaderAndFooter(tableId, data) {

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
        function QuestionBankList_CreateDataTableColumns(headerList) {
            let DataTableColumns = $.map(headerList, function (item, index) {
                if (item == '選取') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `<input type="button" value="選取" qbid="${row['題庫編號']}" />`;
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

        function Init_QuestionBankList() {
            let Method = 'GetQuestionBankList';
            let url = `/api/_ExamGroupManagement.ashx?Method=${Method}`;
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
                let headerList = QuestionBankList_CreateHeaderAndFooter('#QuestionBankList', result[0]);
                var DataTableColumns = QuestionBankList_CreateDataTableColumns(headerList);
            }

            $.each(result, function (i, v) {
                v['建立時間'] = v['建立時間'].replace('T', ' ');
                if (v['更新時間'] != null) { v['更新時間'] = v['更新時間'].replace('T', ' '); }
            });

            let MyTable = $('#QuestionBankList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                order: [[1, "desc"]],
                data: result,
                columns: DataTableColumns,
            }); // end $('#DataList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#QuestionBankList tfoot th').each(function () {
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

        } // end Init_QuestionBankList

        // 建立 DataTable 標頭跟標尾
        function StuList_CreateHeaderAndFooter(tableId, data) {

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
        function StuList_CreateDataTableColumns(headerList) {
            let DataTableColumns = $.map(headerList, function (item, index) {

                if (item == '選取') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `<input type="checkbox" value="${row['學生編號']}" />`;
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

        function Init_StuList() {
            let Method = 'GetStuList';
            let url = `/api/_ExamGroupManagement.ashx?Method=${Method}`;
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
                let headerList = StuList_CreateHeaderAndFooter('#StuList', result[0]);
                var DataTableColumns = StuList_CreateDataTableColumns(headerList);
            }

            let MyTable = $('#StuList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                //order: [[2, "desc"]], // 使用第3個欄位(學年度) 遞減排序
                data: result,
                columns: DataTableColumns,
            }); // end $('#StuList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#StuList tfoot th').each(function () {
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

        } // end Init_StuList

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div style="text-align: center;">
                <h1>測驗管理</h1>
                <hr />
            </div>

            <div>

                <div class="mainDiv">
                    <div class="expandableCollapsibleDiv">
                        <span>
                            <img src="images/up-arrow.jpg" />
                            <a>查看已建立測驗列表</a>
                        </span>
                        <ul>
                            <li>
                                <div>
                                    <h2><span>測驗列表</span></h2>
                                    <table id="ExamList" class="display" style="width: 100%"></table>
                                </div>
                            </li>
                        </ul>
                    </div>

                    <div class="expandableCollapsibleDiv">
                        <span>
                            <img src="images/up-arrow.jpg" />
                            <a>建立測驗</a>
                        </span>
                        <ul>
                            <li>
                                <div>
                                    <h2>
                                        <span>請選擇測驗類型: </span>
                                        <select id="ExamType" style="font-size: x-large;"></select>
                                    </h2>
                                    <hr />
                                </div>

                                <div>
                                    <h2><span>請選擇題庫: </span></h2>
                                    <table id="QuestionBankList" class="display" style="width: 100%"></table>
                                    <br />
                                    <h2>
                                        <span>已選擇題庫 => </span><span id="SelectedQuestionMsg"></span>
                                    </h2>
                                    <hr />
                                </div>

                                <div>
                                    <h2><span>請選擇學生: </span></h2>
                                    <table id="StuList" class="display" style="width: 100%"></table>
                                    <br />
                                    <h2>
                                        <span>已選擇學生:</span><br />
                                        <span id="SelectedStuMsg"></span>
                                    </h2>
                                    <hr />
                                </div>

                                <div style="text-align: center;">
                                    <input id="btnCreate" type="button" value="新增測驗" style="font-size: x-large; width: 300px;" />
                                </div>
                            </li>
                        </ul>
                    </div>
                    <%-- <div class="expandableCollapsibleDiv"> --%>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
