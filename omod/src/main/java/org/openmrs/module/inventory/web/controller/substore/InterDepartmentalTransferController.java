/**
 * 
 */
package org.openmrs.module.inventory.web.controller.substore;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.math.NumberUtils;
import org.openmrs.Role;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugCategory;
import org.openmrs.module.hospitalcore.model.InventoryDrugFormulation;
import org.openmrs.module.hospitalcore.model.InventoryStore;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugTransaction;
import org.openmrs.module.hospitalcore.model.InventoryStoreDrugTransactionDetail;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.inventory.web.controller.global.StoreSingleton;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Ghanshyam
 *
 */
@Controller("InterDepartmentalTransferController")
@RequestMapping("/module/inventory/interDepartmentalTransfer.form")
public class InterDepartmentalTransferController {

	@RequestMapping(method = RequestMethod.GET)
	public String firstView(
	        @RequestParam(value = "categoryId", required = false) Integer categoryId,
	        Model model) {

	    InventoryService inventoryService =
	            (InventoryService) Context.getService(InventoryService.class);

	    InventoryStore currentStore = inventoryService.getStoreByCollectionRole(
	            new ArrayList<Role>(Context.getAuthenticatedUser().getAllRoles()));

	    model.addAttribute("store", currentStore);
	    model.addAttribute("date", new Date());

	    List<InventoryDrugCategory> listCategory =
	            inventoryService.findDrugCategory("");

	    model.addAttribute("listCategory", listCategory);
	    model.addAttribute("categoryId", categoryId);

	    if (categoryId != null && categoryId > 0) {
	        model.addAttribute("drugs",
	                inventoryService.findDrug(categoryId, null));
	    }

	    // Destination Stores
	    List<InventoryStore> stores = inventoryService.listAllInventoryStore();
	    List<InventoryStore> subStores = new ArrayList<InventoryStore>();

	    for (InventoryStore s : stores) {

	        if (s.getParent() == null) {
	            continue;
	        }

	        if (s.getId().equals(currentStore.getId())) {
	            continue;
	        }

	        subStores.add(s);
	    }

	    model.addAttribute("subStores", subStores);

	    // **************** Transfer Slip ****************

	    int userId = Context.getAuthenticatedUser().getId();

	    String forwardParam = "transferDrugDetail_" + userId;

	    List<InventoryStoreDrugTransactionDetail> transferList =
	            (List<InventoryStoreDrugTransactionDetail>)
	            StoreSingleton.getInstance().getHash().get(forwardParam);

	    if (transferList == null) {
	        transferList = new ArrayList<InventoryStoreDrugTransactionDetail>();
	    }

	    model.addAttribute("transferList", transferList);

	    return "/module/inventory/substore/interDepartmentalTransfer";
	}

	@RequestMapping(params = "addTransfer", method = RequestMethod.POST)
	public String addTransfer(HttpServletRequest request, Model model) {

	    InventoryService inventoryService =
	            (InventoryService) Context.getService(InventoryService.class);

	    int userId = Context.getAuthenticatedUser().getId();

	    Integer drugId = NumberUtils.toInt(request.getParameter("drugId"), 0);
	    Integer formulationId = NumberUtils.toInt(request.getParameter("formulation"), 0);
	    Integer destinationStoreId = NumberUtils.toInt(request.getParameter("destinationStore"), 0);
	    Integer quantity = NumberUtils.toInt(request.getParameter("quantity"), 0);

	    InventoryDrug drug = inventoryService.getDrugById(drugId);
	    InventoryDrugFormulation formulation =
	            inventoryService.getDrugFormulationById(formulationId);
	    InventoryStore destinationStore =
	            inventoryService.getStoreById(destinationStoreId);

	    String forwardParam = "transferDrugDetail_" + userId;

	    List<InventoryStoreDrugTransactionDetail> transferList =
	            (List<InventoryStoreDrugTransactionDetail>)
	            StoreSingleton.getInstance().getHash().get(forwardParam);

	    if (transferList == null) {
	        transferList = new ArrayList<InventoryStoreDrugTransactionDetail>();
	    }

	    // Find stock batch (FIFO)
	    InventoryStore sourceStore =
	            inventoryService.getStoreByCollectionRole(
	                    new ArrayList<Role>(
	                            Context.getAuthenticatedUser().getAllRoles()));

	    List<InventoryStoreDrugTransactionDetail> stockList =
	            inventoryService.listStoreDrugTransactionDetail(
	                    sourceStore.getId(),
	                    drugId,
	                    formulationId,
	                    true);

	    if (stockList == null || stockList.isEmpty()) {
	        return "redirect:/module/inventory/interDepartmentalTransfer.form";
	    }

	    InventoryStoreDrugTransactionDetail stock = stockList.get(0);

	    // Create transfer item
	    InventoryStoreDrugTransactionDetail item =
	            new InventoryStoreDrugTransactionDetail();

	    item.setTransaction(stock.getTransaction());
	    item.setDrug(drug);
	    item.setFormulation(formulation);
	    item.setParent(stock);

	    item.setBatchNo(stock.getBatchNo());
	    item.setCompanyName(stock.getCompanyName());
	    item.setDateManufacture(stock.getDateManufacture());
	    item.setDateExpiry(stock.getDateExpiry());

	    item.setQuantity(quantity);
	    item.setIssueQuantity(quantity);
	    System.out.println("kkkkkkkkkk-"+destinationStore.getId());

	    // keep destination temporarily
	    item.setAttribute(String.valueOf(destinationStore.getId()));
	    item.setSecondAttribute(String.valueOf(destinationStore.getName()));
	    //item.setReceiptFrom(String.valueOf(destinationStore.getId()));

	    transferList.add(item);

	    StoreSingleton.getInstance().getHash().put(forwardParam, transferList);

	    return "redirect:/module/inventory/interDepartmentalTransfer.form";
	}
	
	@RequestMapping(params = "saveTransfer", method = RequestMethod.POST)
	public String saveTransfer(HttpServletRequest request) {

	    InventoryService inventoryService =
	            (InventoryService) Context.getService(InventoryService.class);

	    int userId = Context.getAuthenticatedUser().getId();

	    String forwardParam = "transferDrugDetail_" + userId;

	    List<InventoryStoreDrugTransactionDetail> transferList =
	            (List<InventoryStoreDrugTransactionDetail>)
	            StoreSingleton.getInstance().getHash().get(forwardParam);

	    if (transferList == null || transferList.isEmpty()) {
	        return "redirect:/module/inventory/interDepartmentalTransfer.form";
	    }

	    Date now = new Date();

	    InventoryStore sourceStore =
	            inventoryService.getStoreByCollectionRole(
	                    new ArrayList<Role>(
	                            Context.getAuthenticatedUser().getAllRoles()));

	    //=========================================
	    // GROUP ITEMS BY DESTINATION STORE
	    //=========================================

	    Map<Integer,List<InventoryStoreDrugTransactionDetail>> map =
	            new HashMap<Integer,List<InventoryStoreDrugTransactionDetail>>();

	    for(InventoryStoreDrugTransactionDetail item : transferList){

	        Integer destinationId =
	                Integer.parseInt(item.getAttribute());

	        if(!map.containsKey(destinationId)){
	            map.put(destinationId,
	                    new ArrayList<InventoryStoreDrugTransactionDetail>());
	        }

	        map.get(destinationId).add(item);
	    }

	    //=========================================
	    // PROCESS EACH DESTINATION STORE
	    //=========================================

	    for(Integer destinationId : map.keySet()){

	        InventoryStore destinationStore =
	                inventoryService.getStoreById(destinationId);

	        // OUT Transaction (Source)
	        InventoryStoreDrugTransaction issueTxn =
	                new InventoryStoreDrugTransaction();

	        issueTxn.setStore(sourceStore);
	        issueTxn.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
	        issueTxn.setCreatedOn(now);
	        issueTxn.setStatus(InventoryStoreDrugTransaction.STATUS_DONE);
	        issueTxn.setTypeTransaction(2);
	        issueTxn.setDescription(
	                "Inter Department Transfer To "
	                        + destinationStore.getName());

	        issueTxn =
	                inventoryService.saveStoreDrugTransaction(issueTxn);

	        // IN Transaction (Destination)
	        InventoryStoreDrugTransaction receiptTxn =
	                new InventoryStoreDrugTransaction();

	        receiptTxn.setStore(destinationStore);
	        receiptTxn.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
	        receiptTxn.setCreatedOn(now);
	        receiptTxn.setStatus(InventoryStoreDrugTransaction.STATUS_DONE);
	        receiptTxn.setTypeTransaction(1);
	        receiptTxn.setDescription(
	                "Received From "
	                        + sourceStore.getName());

	        receiptTxn =
	                inventoryService.saveStoreDrugTransaction(receiptTxn);

	        //=================================
	        // SAVE EVERY DRUG
	        //=================================

	        for(InventoryStoreDrugTransactionDetail item :
	                map.get(destinationId)){

	            
	        	List<InventoryStoreDrugTransactionDetail> batchList =
	        	        inventoryService.listStoreDrugTransactionDetail(
	        	                sourceStore.getId(),
	        	                item.getDrug().getId(),
	        	                item.getFormulation().getId(),
	        	                true);

	        	int remainingQty = item.getQuantity();
	        	
	        	Integer sourceRunningBalance =
	        	        inventoryService.sumCurrentQuantityDrugOfStore(
	        	                sourceStore.getId(),
	        	                item.getDrug().getId(),
	        	                item.getFormulation().getId());

	        	Integer destinationRunningBalance =
	        	        inventoryService.getClosingBalanceOfStore(
	        	                destinationStore.getId(),
	        	                item.getDrug().getId(),
	        	                item.getFormulation().getId());

	        	if(destinationRunningBalance == null){
	        	    destinationRunningBalance = 0;
	        	}
	        	
	        	for (InventoryStoreDrugTransactionDetail parent : batchList) {

	        	    if (remainingQty <= 0)
	        	        break;

	        	    if (parent.getCurrentQuantity() <= 0)
	        	        continue;

	        	    int transferQty = Math.min(parent.getCurrentQuantity(), remainingQty);

	        	    Integer opening = sourceRunningBalance;

	        	    // Reduce stock
	        	    parent.setCurrentQuantity(parent.getCurrentQuantity() - transferQty);
	        	    inventoryService.saveStoreDrugTransactionDetail(parent);

	        	    //==========================
	        	    // ISSUE ENTRY
	        	    //==========================

	        	    InventoryStoreDrugTransactionDetail issue =
	        	            new InventoryStoreDrugTransactionDetail();

	        	    issue.setTransaction(issueTxn);
	        	    issue.setDrug(parent.getDrug());
	        	    issue.setFormulation(parent.getFormulation());

	        	    issue.setBatchNo(parent.getBatchNo());
	        	    issue.setCompanyName(parent.getCompanyName());

	        	    issue.setDateManufacture(parent.getDateManufacture());
	        	    issue.setDateExpiry(parent.getDateExpiry());
	        	    issue.setReceiptDate(parent.getReceiptDate());

	        	    issue.setQuantity(0);
	        	    issue.setIssueQuantity(transferQty);
	        	    issue.setCurrentQuantity(0);
	        	    issue.setMrpPrice(parent.getMrpPrice());

	        	    issue.setOpeningBalance(sourceRunningBalance);

	        	    Integer sourceClosing = sourceRunningBalance - transferQty;

	        	    issue.setClosingBalance(sourceClosing);

	        	    sourceRunningBalance = sourceClosing;

	        	    issue.setCreatedOn(now);

	        	    issue.setParent(parent);

	        	    inventoryService.saveStoreDrugTransactionDetail(issue);

	        	    //==========================
	        	    // RECEIPT ENTRY
	        	    //==========================

	        	    InventoryStoreDrugTransactionDetail receipt =
	        	            new InventoryStoreDrugTransactionDetail();

	        	    receipt.setTransaction(receiptTxn);

	        	    receipt.setDrug(parent.getDrug());
	        	    receipt.setFormulation(parent.getFormulation());

	        	    receipt.setBatchNo(parent.getBatchNo());
	        	    receipt.setCompanyName(parent.getCompanyName());

	        	    receipt.setDateManufacture(parent.getDateManufacture());
	        	    receipt.setDateExpiry(parent.getDateExpiry());
	        	    receipt.setReceiptDate(parent.getReceiptDate());

	        	    Integer openingQty = destinationRunningBalance;
	        	    System.out.println("hhhhhhhhh-"+openingQty);
	        	    Integer closingQty = destinationRunningBalance + transferQty;

	        	    receipt.setQuantity(transferQty);

	        	    receipt.setCurrentQuantity(transferQty);

	        	    	receipt.setIssueQuantity(0);

	        	    	receipt.setOpeningBalance(destinationRunningBalance);

	        	    	receipt.setClosingBalance(closingQty);
	        	    	 System.out.println("kkkkkkkkkkkkkkkkk-"+closingQty);
	        	    	 receipt.setMrpPrice(parent.getMrpPrice());

	        	    	destinationRunningBalance = closingQty;
	        	    	
	        	    	receipt.setCreatedOn(now);

	        	    receipt.setParent(parent);

	        	    inventoryService.saveStoreDrugTransactionDetail(receipt);

	        	    remainingQty -= transferQty;
	        	}
	           
	        }
	    }

	    StoreSingleton.getInstance().getHash().remove(forwardParam);

	    return "redirect:/module/inventory/interDepartmentalTransfer.form";
	}
	
	@RequestMapping(params = "clearTransfer", method = RequestMethod.POST)
	public String clearTransfer() {

	    int userId = Context.getAuthenticatedUser().getId();

	    StoreSingleton.getInstance().getHash()
	            .remove("transferDrugDetail_" + userId);

	    return "redirect:/module/inventory/interDepartmentalTransfer.form";
	}
    
}
