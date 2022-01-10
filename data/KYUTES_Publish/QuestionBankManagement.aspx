<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionBankManagement.aspx.cs" Inherits="KYUTES.QuestionBankManagement" %>

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
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/lodash/dist/lodash.min.js"></script>

    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>

        $(document).ready(function () {
            Init_Block();
            Init_DataList();
            Init_SubjectList();
            Init_LevelList();
            Init_TestTime();
            Init_QuestionCount();
            SetListener();
        });

        function Init_Block() {
            $('.Create').show();
            $('.Update').hide();
        }

        function Init_TestTime() {
            $('#TestTime').empty();

            let data = _.range(1, 7).map(x => x * 10);
            $.each(data, function (idx, val) {
                $('#TestTime').append(`<option value='${val}'>${val}</option>`);
            });
        }

        function Init_QuestionCount() {
            $('#QuestionCount').empty();

            let data = [1, 2, 4, 5, 10, 20, 25, 50];
            $.each(data, function (idx, val) {
                $('#QuestionCount').append(`<option value='${val}'>${val}</option>`);
            });
        }

        function SetListener() {
            $('#btnCreate').click(function () {
                let flag = confirm(`確定要新增嗎？`);
                if (!flag) { return false; }

                CreateQuestionBank();
            });

            $('#CreateOrUpdateQuestionBank').change(function () {
                let action = $(this).val();

                if (action == 'c') {
                    $('.Create').show();
                    $('.Update').hide();
                } else if (action == 'u') {
                    $('.Update').show();
                    $('.Create').hide();

                    Init_QuestionBankIdList();
                }
            });

            $('#QuestionBankId').change(function () {
                let QBId = $(this).val();
                SetQuestionBankBlock(QBId);
            });

            $('#btnUpdate').click(function () {
                let flag = confirm('確定要更新嗎？');
                if (!flag) { return false; }

                UpdateQuestionBank();
            });

        } // end SetListener

        function UpdateQuestionBank() {

            let QuestionBankId = $('#QuestionBankId').val();
            let QuestionBankName = $('#QuestionBankName').val();
            let SubjectId = $('#Subject').val();
            let Level = $('#Level').val();
            let TestTime = $('#TestTime').val();
            let QuestionCount = $('#QuestionCount').val();

            let Method = 'UpdateQuestionBank';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let Parameters = {
                QuestionBankId: QuestionBankId,
                QuestionBankName: QuestionBankName,
                SubjectId: SubjectId,
                Level: Level,
                TestTime: TestTime,
                QuestionCount: QuestionCount
            };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('更新成功');
                location.reload();
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end UpdateQuestionBank

        function SetQuestionBankBlock(QBId) {
            let Method = 'GetQuestionBankInfo';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let Parameters = { QBId: QBId };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                let QBInfo = result['Data'];

                let QuestionBankName = QBInfo['QuestionBankName'];
                let SubjectId = QBInfo['SubjectId'];
                let Level = QBInfo['Level'];
                let TestTime = QBInfo['TestTime'];
                let QuestionCount = QBInfo['QuestionCount'];

                $('#QuestionBankName').val(QuestionBankName);
                $('#Subject').val(SubjectId);
                $('#Level').val(Level);
                $('#TestTime').val(TestTime);
                $('#QuestionCount').val(QuestionCount);
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end SetQuestionBankBlock

        function Init_QuestionBankIdList() {
            let Method = 'GetQuestionBankIdList';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#QuestionBankId').empty();

                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#QuestionBankId').append(`<option value='${val['id']}'>${val['id']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_QuestionBankIdList

        function CreateQuestionBank() {

            let QuestionBankName = $('#QuestionBankName').val();
            let SubjectId = $('#Subject').val();
            let Level = $('#Level').val();
            let TestTime = $('#TestTime').val();
            let QuestionCount = $('#QuestionCount').val();

            let Method = 'CreateQuestionBank';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let Parameters = {
                QuestionBankName: QuestionBankName,
                SubjectId: SubjectId,
                Level: Level,
                TestTime: TestTime,
                QuestionCount: QuestionCount
            };

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

        } // end CreateQuestionBank

        function Init_SubjectList() {
            let Method = 'GetSubjectList';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#Subject').empty();

                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#Subject').append(`<option value='${val['id']}'>${val['SubjectName']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_SubjectList

        function Init_LevelList() {
            let Method = 'GetLevelList';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#Level').empty();

                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#Level').append(`<option value='${val['id']}'>${val['Descript']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_LevelList

        // 建立 DataTable 標頭跟標尾
        function CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });
            //headerList.unshift('選取'); // 從list前端加入元素

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
                //if (item == '選取') {
                //    item = {
                //        "render": function (data, type, row, meta) {
                //            data = `<input type='checkbox' class='ckbxBig' value='${row['題目編號']}' />`;
                //            return data;
                //        }
                //    };
                //} else {
                //    item = { "data": item };
                //}
                item = { "data": item };
                return item;
            });

            return DataTableColumns;
        } // end CreateDataTableColumns

        function Init_DataList() {
            let Method = 'GetDataList';
            let url = `/api/_QuestionBankManagement.ashx?Method=${Method}`;
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
                let headerList = CreateHeaderAndFooter('#DataList', result[0]);
                var DataTableColumns = CreateDataTableColumns(headerList);
            }

            $.each(result, function (i, v) {
                v['建立時間'] = v['建立時間'].replace('T', ' ');
                if (v['更新時間'] != null) { v['更新時間'] = v['更新時間'].replace('T', ' '); }
            });

            let MyTable = $('#DataList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                order: [[0, "desc"]],
                data: result,
                columns: DataTableColumns,
            }); // end $('#DataList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#DataList tfoot th').each(function () {
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

        } // end Init_DataList

    </script>

</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>題庫管理</h1>
                <hr />
                <table id="DataList" class="display" style="width: 100%"></table>
                <hr />
            </div>

            <div>
                <h1>
                    <span>請選擇操作類型: </span>
                    <select id="CreateOrUpdateQuestionBank" style="font-size: x-large;">
                        <option value="c">新增題庫</option>
                        <option value="u">更新題庫</option>
                    </select>
                </h1>

                <p class="Update">
                    <span>題庫編號 </span>
                    <select id="QuestionBankId" class="Update"></select>
                </p>

                <span>題庫名稱 </span>
                <input id="QuestionBankName" placeholder="使用者自訂..." />
                <br />

                <span>科目類型 </span>
                <select id="Subject"></select>
                <br />

                <span>難易程度 </span>
                <select id="Level"></select>
                <br />

                <span>測驗時間 </span>
                <select id="TestTime"></select>
                <span>分</span>
                <br />

                <span>題目數量 </span>
                <select id="QuestionCount"></select>
                <span>題</span><br />

                <input id="btnCreate" type="button" value="新增" class="Create" />
                <input id="btnUpdate" type="button" value="更新" class="Update" />
            </div>

        </div>
    </form>
</body>
</html>
