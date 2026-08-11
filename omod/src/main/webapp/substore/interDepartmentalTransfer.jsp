<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Add/Edit substore"
otherwise="/login.htm"
redirect="/module/inventory/main.form"/>

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="../includes/js_css.jsp" %>

<script type="text/javascript">
function confirmTransfer() {

    return confirm("Are you sure you want to transfer the selected drugs?");
}

function validateTransfer() {

    var destinationStore = $("#destinationStore").val();

    if (destinationStore == null || destinationStore == "") {
        alert("Please select Transfer To Store");
        $("#destinationStore").focus();
        return false;
    }

    var drugId = $("#drugId").val();

    if (drugId == null || drugId == "") {
        alert("Please select Drug");
        $("#drugName").focus();
        return false;
    }

    var formulation = $("#formulation").val();

    if (formulation == null || formulation == "") {
        alert("Please select Formulation");
        return false;
    }

    var available = parseInt($("#availableQty").val()) || 0;
    var qty = parseInt($("#quantity").val()) || 0;

    if (qty <= 0) {
        alert("Please enter transfer quantity");
        $("#quantity").focus();
        return false;
    }

    if (qty > available) {
        alert("Transfer quantity cannot be greater than available quantity.\nAvailable Quantity : " + available);
        $("#quantity").focus();
        return false;
    }

    return true;
}

</script>

<div style="width:50%;float:left;">

<b class="boxHeader">
Transfer Drug To Another Pharmacy
</b>

<div class="box">

<form method="post" id="interDepartmentalTransfer">

<table class="box">

<tr>
    <td>From Store</td>
    <td>
        <b>${store.name}</b>
    </td>
</tr>

<tr>
    <td>Transfer To <em>*</em></td>

    <td>

        <select name="destinationStore" id="destinationStore">

            <option value="">Please Select</option>

            <c:forEach items="${subStores}" var="s">

                <option value="${s.id}">
                    ${s.name}
                </option>

            </c:forEach>

        </select>

    </td>

</tr>

<tr>
    <td>Drug <em>*</em></td>
    <td>
        <input id="drugName"
               name="drugName"
               onblur="INDENT.onBlurDrugTransfer(this);"
               style="width:200px;"/>

        <input type="hidden"
               id="drugId"
               name="drugId"/>

        <div id="divDrug"></div>
    </td>
</tr>

<tr>
    <td>Formulation <em>*</em></td>
    <td>
        <div id="divFormulation">
         <select id="formulation" name="formulation">
                <option value="">Please Select Formulation</option>
            </select>
        </div>
    </td>
</tr>

<tr>

    <td>Quantity</td>

     <td>
        <input type="text"
               id="quantity" name="quantity"
               value="0"/>
    </td>

</tr>

<tr>
<td>
Available Quantity
</td>

<td>

<input type="text"
       id="availableQty" name="availableQty"
       readonly="true"
       value="0"/>

</td>
</tr>

</table>

<br/>

<input type="submit" name="addTransfer"
class="ui-button ui-widget ui-state-default ui-corner-all"
value="Add Transfer"/>

</form>

</div>

</div>

<div style="width:47%;float:right;">

<b class="boxHeader">

Transfer Slip

</b>

<div class="box">
<form method="post"
      action="interDepartmentalTransfer.form">

<table class="box" width="100%">

<tr>

<th>#</th>

<th>Drug</th>

<th>Formulation</th>

<th>Qty</th>

<th>Destination SubStore</th>

</tr>

<c:forEach items="${transferList}" var="item" varStatus="status">

<tr>

<td>${status.count}</td>

<td>${item.drug.name}</td>

<td>${item.formulation.name}-${item.formulation.dozage}</td>

<td>${item.quantity}</td>

<td>${item.secondAttribute}</td>

</tr>

</c:forEach>

</table>

<br/>

<input type="submit" name="saveTransfer"
       value="Save Transfer" onclick="return confirmTransfer();"
       class="ui-button ui-widget ui-state-default ui-corner-all"/>

<input type="submit"
           name="clearTransfer"
           value="Clear"
           class="ui-button ui-widget ui-state-default ui-corner-all"/>

</form>

</div>

</div>

<%@ include file="/WEB-INF/template/footer.jsp" %>