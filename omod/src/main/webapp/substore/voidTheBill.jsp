 <%--
 *  Copyright 2009 Society for Health Information Systems Programmes, India (HISP India)
 *
 *  This file is part of Inventory module.
 *
 *  Inventory module is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  Inventory module is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Inventory module.  If not, see <http://www.gnu.org/licenses/>.
 *
--%> 
<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<jsp:useBean id="now" class="java.util.Date"/>
<openmrs:require privilege="Add/Edit substore" otherwise="/login.htm" redirect="/module/inventory/main.form" />
<br />

<span class="boxHeader">return the drug</span>
<form method="post" class="box">
<input type="hidden"
       id="isPartialVoid"
       name="isPartialVoid"
       value="false"/>
<table width="100%" cellpadding="5" cellspacing="0">
<tr>
					<td>Patient ID :</td>
					<td>${issueDrugPatient.identifier }&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					 
					<td>Name :</td>
			        <td>${issueDrugPatient.patient.givenName}&nbsp;${issueDrugPatient.patient.familyName}</td>
				</tr>
				<tr>
					<td>Age:</td>
					<td><c:choose>
							<c:when test="${issueDrugPatient.patient.age == 0  }">&lt 1</c:when>
							<c:otherwise>${issueDrugPatient.patient.age }</c:otherwise>
						</c:choose>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
						
					<td>Gender:</td>
        	        <td>${issueDrugPatient.patient.gender}</td>  	
				</tr>
				<tr>
					<td>Date:</td>
					<td><openmrs:formatDate date="${date}" type="textbox" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					
					<td>Patient Category:</td>
			        <td>${patientCategory} &nbsp;&nbsp;&nbsp; ${patientSubCategory}</td>
			       
				</tr>
				<tr>
				<td>Bill No:</td>
				<td>${billNo}</td>
				</tr>
<br />
</table>

<table width="100%" cellpadding="5" cellspacing="0">
<tr>
	<th id="chkHeader" style="visibility:hidden;">Select</th>
    <th>#</th>
	<th>Drug Name</th>
	<th>Formulation</th>
	<th>DOE</th>
	<th>Issued Quantity</th>
	<th id="qtyHeader" style="visibility:hidden;">
Return Qty
</th>
	<!-- <th>Action</th> -->
	</tr>
<c:choose>
	<c:when test="${not empty storeDrugTransactionDetailList}">
	<c:forEach items="${storeDrugTransactionDetailList}" var="tranDetail" varStatus="varStatus">
	<tr id="tranRow${tranDetail.id}"
    name="tranRow${tranDetail.id}"
    class='${varStatus.index % 2 == 0 ? "oddRow" : "evenRow" }
           <c:if test="${tranDetail.voided==1}"> strikeRow </c:if>'>
		<td class="chkColumn" style="visibility:hidden;">
   <input type="checkbox"
       class="voidDrug"
       id="selectedTranDetail"
       name="selectedTranDetail"
       value="${tranDetail.id}"
       onclick="toggleReturnQty(this);"
       <c:if test="${tranDetail.voided==1}">
           disabled="disabled"
       </c:if>>
</td>
		<td><c:out value="${(( pagingUtil.currentPage - 1  ) * pagingUtil.pageSize ) + varStatus.count }"/></td>
	     <td> ${tranDetail.drug.name}</td>
	     <td>${tranDetail.formulation.name}-${tranDetail.formulation.dozage}</td>
	     <td><openmrs:formatDate date="${tranDetail.dateExpiry}"
								type="textbox" /></td>
	     <td>${tranDetail.issueQuantity}</td>

<td class="chkColumn" style="display:none;">
   <input type="text"
       id="returnQty${tranDetail.id}"
       name="returnQty${tranDetail.id}"
       value="0"
       style="width:50px;"
       <c:if test="${tranDetail.voided==1}">
           disabled="disabled"
       </c:if>>
</td>
	     <!--
	     <td><a style="color:red" onclick="removeDrug(${tranDetail.id},${tranDetail.mrpPrice},${tranDetail.issueQuantity});">[X]</a></td>
	     -->
	     <td><input type="hidden" id="quantity${tranDetail.id}" name="quantity${tranDetail.id}" value="${tranDetail.issueQuantity}"></td>
	     <td><input type="hidden" id="mrp${tranDetail.id}" value="${tranDetail.mrpPrice}"></td>
	     <td><input type="hidden" id="tranDetail" name="tranDetail" value="${tranDetail.id}"></td>
	     <td><input type="hidden" id="issuedQty${tranDetail.id}" value="${tranDetail.issueQuantity}"></td>
</tr>
</c:forEach>
</c:when>
</c:choose>

<tr>
    <td colspan="4"></td>
    <td>Voided Reason <label style="color:red">*</label></td>
    <td colspan="3">
        <input type="text" id="voidedReason" name="voidedReason">
    </td>
</tr>

<tr>
    <td colspan="4"></td>
    <td>Discount %</td>
    <td colspan="3">
        <input type="text" id="waiverPercentage"
               name="waiverPercentage"
               readonly="readonly">
    </td>
</tr>

<tr>
    <td colspan="4"></td>
    <td>Cash Returned</td>
    <td colspan="3">
        <input type="text"
               id="cashReturned"
               name="cashReturned"
               readonly="readonly"
               value="0">
    </td>
</tr>

<tr>
    <td colspan="3" align="center">

        <input type="button"
               id="receipt"
               value="Void Bill"
               onclick="submitFullVoid();"/>

        &nbsp;&nbsp;

        <input type="button"
               id="partialVoid"
               value="Partial Void"
               onclick="submitPartialVoid();"/>

        <input type="hidden"
               id="actionType"
               name="actionType"
               value="FULL"/>

    </td>
</tr>

</table>
</form>

<script type="text/javascript">
var cashReturnd;
jQuery(document).ready(function(){
<c:forEach var="entry" items="${storeDrugTransactionDetailList}">
jQuery("#waiverPercentage").val(${entry.waiverPercentage});
var credit="${entry.amountCredit}";
if(credit==""){
jQuery("#cashReturned").val(${entry.amountPayable});
cashReturnd=${entry.amountPayable};
}
else{
jQuery("#cashReturned").val(0);
cashReturnd=0;
}
</c:forEach>

// Bind event only once
    jQuery("input[id^='returnQty']").on("input", function () {
        calculateCashReturned();
    });
});

function hidePartialVoid(){

    jQuery("#chkHeader,#qtyHeader").css("visibility","hidden");

    jQuery(".chkColumn").css({
        "display":"none",
        "visibility":"hidden"
    });

    jQuery("#receipt").removeAttr("disabled");

    jQuery("input[id^='returnQty']").val(0);

    //calculateCashReturned();
}

function submitFullVoid(){

    // If currently in Partial Void mode, switch back to Full Void UI
    hidePartialVoid();
    
    // first click
   if(jQuery("#isPartialVoid").val()=="true"){
        jQuery("#isPartialVoid").val("false");
        return false;
    }
    
    jQuery("#actionType").val("FULL");
    
    jQuery("#cashReturned").val(cashReturnd);
    

    // normal full void validation
   if(validate()){
        jQuery("form").submit();
    }
}

function submitPartialVoid(){

    // first click
    if(jQuery("#isPartialVoid").val()!="true"){

        showPartialVoid();

        return false;
    }

    // second click
    jQuery("#actionType").val("PARTIAL");

    if(validate()){
        jQuery("form").submit();
    }
}

function enablePartialVoid(){

    jQuery("#isPartialVoid").val("true");

    jQuery("#chkHeader,#qtyHeader").css("visibility","visible");

    jQuery(".chkColumn").css({
        "display":"table-cell",
        "visibility":"visible"
    });

    // Change only button text
    //jQuery("#partialVoid").val("Submit Partial Void");

    // Next click will submit
    jQuery("#partialVoid")
        .off("click")
        .on("click", function(){
            jQuery("#form").submit();
        });
}

function validate(){
var tranDetailArray = new Array();
<c:forEach var="entry" items="${transactionDetailId}">
tranDetailArray.push(${entry});
</c:forEach>

var _quantityMap = new Array();
<c:forEach var="entry" items="${quantityMap}">
_quantityMap[${entry.key}] = "${entry.value}";
</c:forEach>

if (${expired}==1)
{
alert("The List Contains Expired Drugs");
return false;
}
	
for (var i = 0; i < tranDetailArray.length; i++){
var tranDetail=tranDetailArray[i];
var quantity=jQuery("#quantity"+tranDetail).val();

if (quantity==null || quantity=="")
{
alert("Please enter quantity");
return false;
}
if (quantity!=null || quantity!=""){
 if(isNaN(quantity)){
  alert("Please enter quantity in correct format");
  return false;
  }
  var quantityInInteger=parseInt(quantity);
  var issuedQuantity=parseInt(_quantityMap[tranDetail]);
 if(quantityInInteger>issuedQuantity){
 alert("return quantity can not be greater than issue quantity");
 return false;
 }
} 
  
}
var action = jQuery("#actionType").val();
if(action=="FULL"){

    var voidedReason = jQuery("#voidedReason").val();

    if(jQuery.trim(voidedReason)==""){
        alert("Please enter voided reason");
        return false;
    }
}
else if(action=="PARTIAL"){

    var voidedReason = jQuery("#voidedReason").val();

    if(jQuery.trim(voidedReason)==""){
        alert("Please enter partial voided reason");
        return false;
    }

    var checked = jQuery(".voidDrug:checked").length;

    if(checked==0){
        alert("Please select at least one drug.");
        return false;
    }

    jQuery(".voidDrug").each(function(){

        if(jQuery(this).is(":checked")){

            var id=jQuery(this).val();

            var returnQty=jQuery("#returnQty"+id).val();

            if(returnQty=="" || parseInt(returnQty)<=0){
                alert("Please enter return quantity.");
                return false;
            }

            var issueQty=parseInt(jQuery("#quantity"+id).val());

            if(parseInt(returnQty)>issueQty){
                alert("Return quantity cannot exceed issued quantity.");
                return false;
            }

        }

    });

}

if(confirm("Are you sure?")){
jQuery("#receipt").attr("disabled", "disabled");
return true;
}
else{
return false;
}
}

function removeDrug(tranDetailId,mrpPrice,issueQuantity){
var tranDetail=tranDetailId.toString();
jQuery("#tranRow"+tranDetail).hide();
jQuery("#quantity"+tranDetail).val(0);
//var cashReturned=mrpPrice*issueQuantity;
//jQuery("#cashReturned").val(cashReturned);
}

function showPartialVoid(){

    jQuery("#isPartialVoid").val("true");

    jQuery("#chkHeader,#qtyHeader").css("visibility","visible");

    jQuery(".chkColumn").css({
        "display":"table-cell",
        "visibility":"visible"
    });
}

function calculateCashReturned(){

    if(jQuery("#isPartialVoid").val()!="true"){
        return;
    }

    var total = 0;

    var discount = parseFloat(jQuery("#waiverPercentage").val());

    if(isNaN(discount)){
        discount = 0;
    }

    var payablePercent = 100 - discount;

    jQuery(".voidDrug:checked").each(function(){

        var id = jQuery(this).val();

        var qty = parseFloat(jQuery("#returnQty"+id).val());
        if(isNaN(qty)){
            qty = 0;
        }

        var mrp = parseFloat(jQuery("#mrp"+id).val());
        if(isNaN(mrp)){
            mrp = 0;
        }

        total += (qty * mrp * payablePercent) / 100;
    });

    jQuery("#cashReturned").val(total.toFixed(2));
}

function toggleReturnQty(chk){

    var id = chk.value;

    if(chk.checked){
        jQuery("#returnQty"+id).val(jQuery("#issuedQty"+id).val());
    }else{
        jQuery("#returnQty"+id).val(0);
    }

    calculateCashReturned();
}
</script>
<style>
.strikeRow{
    text-decoration: line-through;
    color: #808080;
    background-color: #f5f5f5;
}
</style>