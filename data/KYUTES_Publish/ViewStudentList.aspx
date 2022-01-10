<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewStudentList.aspx.cs" Inherits="KYUTES.ViewStudentList" %>

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

        .LargeWord {
            font-size: x-large;
        }
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>
        $(document).ready(function () {
            Init_StuList();
            Init_DepartmentList();
            SetListener();
        });

        function Init_DepartmentList() {
            let Method = 'GetDepartmentList';
            let url = `/api/_ViewStudentList.ashx?Method=${Method}`;
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

        function SetListener() {
            $("#StuList > tbody").on('click', "input[type='button']", function () {
                let StuAcct = $(this).attr('stuacct');
                GetStuData(StuAcct);
            });

            $('#btnUpdatePersonalData').click(function () {
                let flag = confirm('確定要更新嗎？');
                if (!flag) { return false; }

                UpdatePersonalData();
            });
        } // end SetListener 

        function UpdatePersonalData() {

            let Acct = $('#Acct').text();
            let Name = $('#Name').val();
            let DepartmentId = $('#Department').val();
            let Pwd = $('#Pwd').val();

            let Method = 'UpdatePersonalData';
            let url = `/api/_ViewStudentList.ashx?Method=${Method}`;
            let Parameters = { Acct: Acct, Name: Name, DepartmentId: DepartmentId, Pwd: Pwd };

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

        function GetStuData(Acct) {
            let Method = 'GetStuData';
            let url = `/api/_ViewStudentList.ashx?Method=${Method}`;
            let Parameters = { Acct, Acct };
            let result = CallAPI(url, Parameters);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                let data = result['Data'];
                $('#Acct').text(Acct);
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
        } // end GetStuData

        // 建立 DataTable 標頭跟標尾
        function CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });
            headerList.unshift('更新'); // 從list前端加入元素

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

                if (item == '更新') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `<input type='button' style='font-size: 20px;' stuacct='${row['學生帳號']}' value='更新' />`;
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
            let url = `/api/_ViewStudentList.ashx?Method=${Method}`;
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
                let headerList = CreateHeaderAndFooter('#StuList', result[0]);
                var DataTableColumns = CreateDataTableColumns(headerList);
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
            <h1>檢視學生列表</h1>
            <hr />
            <table id="StuList" class="display" style="width: 100%"></table>
            <hr />
        </div>

        <div class="LargeWord">
            <span>學生帳號 </span>
            <span id="Acct" class="LargeWord"></span>
            <br />
            <br />

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

    </form>
</body>
</html>
