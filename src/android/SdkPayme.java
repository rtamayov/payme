package sdkpayme;

// The native Toast API
import android.os.Bundle;
import android.app.Activity;
import android.widget.Toast;
import android.util.Log;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.Nullable;

import android.util.Base64;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
// Cordova-required packages
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.alignet.api.payme.bean.*;
import com.alignet.api.payme.util.Constants;
import com.alignet.api.payme.wallet.models.EnvDomain;
import com.alignet.api.payme.wallet.pay.activities.PayActivity;

import com.google.gson.Gson;

//import java.util.Random;
/**
 * This class echoes a string called from JavaScript.
 */
public class SdkPayme extends CordovaPlugin {

    private static final String TAG = "SdkPayme";
    private Context context=null;
    private CallbackContext callbackContext = null;
    String text_amount =  "";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(String action,final JSONArray args, CallbackContext newcallbackContext) throws JSONException {
        callbackContext=newcallbackContext;
        Log.d(TAG, "execute plugin");
        if (action.equals("coolMethod")) {            
            Log.d(TAG,"Into Coolmethod of If");
            this.cordova.getActivity().runOnUiThread(new Runnable(){
                public void run(){
                    try{
                        Log.d(TAG,"Into runOnUiThread");
                        JSONObject Jobject = new JSONObject(args.getString(0));
                        coolMethod(Jobject);
                    }catch(Exception e){
                        callbackContext.error(e.getMessage());
                        Log.d(TAG,"Error"+e.getMessage());
                    }
                    
                }
            });
            return true;
        }
        PluginResult pluginResult = new  PluginResult(PluginResult.Status.NO_RESULT);
        pluginResult.setKeepCallback(true);
        return false;
    }

    private final void coolMethod(final JSONObject params) throws JSONException{
        //Context c=cordova.getActivity().getApplicationContext();
        //Toast.makeText(c,params.toString(),Toast.LENGTH_LONG).show();
        Log.d(TAG,"Into coolMethod method");
        //Random random = new Random();
        //String generatedPassword = String.format("%04d", random.nextInt(10000));

        final String text_currency_code = params.getString("code");
        final String text_currency_symbol = params.getString("symbol");

        final String text_number = decrypt(params.getString("operationNumber"));
        
        text_amount=params.getString("amount");
        final String text_product_description = params.getString("productDescription");
        final String text_locale = params.getString("locale");
        final String text_user = params.getString("userCommerce");
        final String text_plan_quota = params.getString("planQuota");
        final String spinner_brands = params.getString("brands");
        final String[] brandsArray = spinner_brands.split(",");

        final String signatureKey = decrypt(params.getString("signatureKey"));
        final String text_merchant = decrypt(params.getString("identifier"));

        PersonaData person = new PersonaData(params.getString("firstName"),
                params.getString("lastName"), params.getString("email"),
                params.getString("address"), params.getString("zip"), params.getString("city"), 
                params.getString("state"),params.getString("country"), params.getString("phone")
        );
        Log.d(TAG,"Set PersonaData");
        CurrencyData currency = new CurrencyData(text_currency_code, text_currency_symbol);
        Log.d(TAG,"Set CurrencyData");
        OperationData operationData = new OperationData(
                text_number, text_amount,
                text_product_description, currency);
        Log.d(TAG,"Set OperationData");
        MerchantData merchantData = new MerchantData(operationData, person, person, person, signatureKey);
        Log.d(TAG,"Set MerchantData");
        SettingsData settingsData = new SettingsData(text_locale, text_merchant, brandsArray);
        Log.d(TAG,"Set SettingsData");
        FeatureWalletData featureWallet = new FeatureWalletData(text_user);
        Log.d(TAG,"Set FeatureWalletData");
        FeaturedReservedData reservedData[] = {
                new FeaturedReservedData(params.getString("name"),params.getString("value")),
                new FeaturedReservedData("reserved2","2"),
                new FeaturedReservedData("reserved3","3")};
        Log.d(TAG,"Set FeaturedReservedData");
        Boolean planQuota = text_plan_quota.equals("1");

        FeaturesData featuresData = new FeaturesData(featureWallet, reservedData, planQuota);
        Log.d(TAG,"Set FeaturesData");
        MerchantOperationData merchantOperation = new MerchantOperationData(
                merchantData, settingsData, featuresData);
        Log.d(TAG,"Set MerchantOperationData");
      	Log.d(TAG,merchantOperation.toString());
        
        String environment=params.getString("environment");
        String URL = "2";
        Log.d(TAG,environment);
        Log.d(TAG,String.valueOf(environment.getClass().getName()));
        Log.d(TAG+"PROD",EnvDomain.PRODUCTION.getUrl());
        Log.d(TAG+"DEV",EnvDomain.DEVELOPMENT.getUrl());
        
        switch (environment){
            case "1":
                Log.d(TAG,"GET PROD");
                URL = EnvDomain.PRODUCTION.getUrl();
                break;
            case "2":
                Log.d(TAG,"GET DEV");
                URL = EnvDomain.DEVELOPMENT.getUrl();
                break;
        }
        Log.d(TAG,URL);

        Bundle bundle = new Bundle();
        bundle.putString(Constants.EXTRA_MERCHANT_ENVDOMAIN, URL);
        bundle.putParcelable(Constants.EXTRA_MERCHANT_OPERATION, merchantOperation);
        Log.d(TAG,"Set SetBundle");
        Log.d(TAG,"Set All values");
        context=cordova.getActivity().getApplicationContext();
        Log.d(TAG,"Get Context");
        Intent intent = new Intent(context, PayActivity.class);
        intent.putExtra(Constants.PAYME_BUNDLE,bundle);        
        Log.d(TAG,"startIntent");

        this.cordova.startActivityForResult((CordovaPlugin) this,intent, Constants.REQUEST_CODE_PAYME);
    }


    @Override
    public void onActivityResult(final int requestCode,final  int resultCode,final @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Log.d(TAG,"onActivityResult");
        if(data!=null){
            Log.d(TAG,"Data Response not null");
            Bundle responseBundle = data.getBundleExtra(Constants.PAYME_RESPONSE_BUNDLE);
            PaymentData parcelableResponse = responseBundle.getParcelable(Constants.EXTRA_PAYMENT);    
        
            if(resultCode == cordova.getActivity().RESULT_OK) {
                if (requestCode == Constants.REQUEST_CODE_PAYME) {        
                    try{
                        String rs=createJsonResponse(parcelableResponse);                    
                        Log.d("Result log:",rs+" "+parcelableResponse);
                        PluginResult pluginResult = new  PluginResult(PluginResult.Status.OK,rs);
                        callbackContext.sendPluginResult(pluginResult);
                    }
                    catch(JSONException e){
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.JSON_EXCEPTION , e.getMessage());
                        callbackContext.sendPluginResult(pluginResult);
                    }catch(Exception e){
                        PluginResult pluginResult = new  PluginResult(PluginResult.Status.ERROR,e.getMessage());
                        callbackContext.sendPluginResult(pluginResult);
                    }        
                }
            }
        }else{
            Log.d(TAG,"Data Response null");
            Log.d(TAG,"resultCode:"+resultCode+"=cordova.getActivity().RESULT_OK"+cordova.getActivity().RESULT_OK);            
            Log.d(TAG,"requestCode:"+requestCode+"=Constants.REQUEST_CODE_PAYME"+Constants.REQUEST_CODE_PAYME);            
            if (requestCode == Constants.REQUEST_CODE_PAYME) {        
                try{
                    String rs=createJsonResponseEmpty();                        
                    Log.d(TAG,"Response:"+rs);
                    PluginResult pluginResult = new  PluginResult(PluginResult.Status.OK,rs);
                    callbackContext.sendPluginResult(pluginResult);
                }
                catch(JSONException e){
                    Log.d(TAG,"Catch Json:"+e.getMessage());
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.JSON_EXCEPTION , e.getMessage());
                    callbackContext.sendPluginResult(pluginResult);
                }catch(Exception e){
                    Log.d(TAG,"Catch Exception:"+e.getMessage());
                    PluginResult pluginResult = new  PluginResult(PluginResult.Status.ERROR,e.getMessage());
                    callbackContext.sendPluginResult(pluginResult);
                }        
            }
        }
    }


public String decrypt(String textencrypt) {
        String[] list = new String[0];
        try {

            String stringKey = "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 5yrFp+iZY/hKT2x0q/R86oOz6Vf19Q==";
            byte[] keyBytes = Base64.decode(stringKey, Base64.DEFAULT);
            String painText = textencrypt;
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");

            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);

            PrivateKey privateKey = keyFactory.generatePrivate(keySpec);

            Cipher cipher = Cipher.getInstance("RSA");
            cipher.init(Cipher.DECRYPT_MODE, privateKey);
            byte[] encryptedMessageBytes = Base64.decode(painText, Base64.DEFAULT);
            //byte[] textout=Arrays.copyOfRange(encryptedMessageBytes,1,encryptedMessageBytes.length);
            byte[] textdDecrypt = cipher.doFinal(encryptedMessageBytes);
            String codeTrash = new String(textdDecrypt, "UTF-8");
            list = codeTrash.split("cryptoentel");


        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchPaddingException e) {
            e.printStackTrace();
        } catch (InvalidKeySpecException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        } catch (BadPaddingException e) {
            e.printStackTrace();
        } catch (IllegalBlockSizeException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        Log.d(TAG,"Catch Json:"+list[1]);
        return list[1];
    }


    public String createJsonResponse(PaymentData paymentData) throws JSONException {
        PaymentResponseData p=paymentData.getPayment();
        FeaturesResponseData f=paymentData.getFeatures();
        FeaturedReservedData r[]=null;
        PlanQuotaData pq=null;

        if(f!=null){
        r=f.getReserved();
        pq=f.getPlanQuota();}

        JSONObject main=new JSONObject();
        main.put("success",paymentData.getSuccess());
        main.put("messageCode",validateEmptyOrNull(paymentData.getMessageCode()));
        main.put("message",validateEmptyOrNull(paymentData.getMessage()));
        main.put("amount",text_amount);

        JSONObject payment=new JSONObject();
        if(p==null) {
            payment.put("accepted",false);
            payment.put("resultCode", " ");
            payment.put("resultMessage", " ");
            payment.put("authorizationResult", " ");
            payment.put("referenceCode", " ");
            payment.put("brand", " ");
            payment.put("bin", " ");
            payment.put("lastPan", " ");
            payment.put("transactionIdentifier"," ");
            payment.put("errorCode", " ");
            payment.put("errorMessage", " ");
            payment.put("date", " ");
            payment.put("hour", " ");
            payment.put("authorizationCode"," ");
            payment.put("operationNumber", " ");
        }else{
            payment.put("accepted", p.getAccepted());
            payment.put("resultCode", validateEmptyOrNull(p.getResultCode()));
            payment.put("resultMessage", validateEmptyOrNull(p.getResultCode()));
            payment.put("authorizationResult", validateEmptyOrNull(p.getAuthorizationResult()));
            payment.put("referenceCode", validateEmptyOrNull(p.getReferenceCode()));
            payment.put("brand", validateEmptyOrNull(p.getBrand()));
            payment.put("bin", validateEmptyOrNull(p.getBin()));
            payment.put("lastPan", validateEmptyOrNull(p.getLastPan()));
            payment.put("transactionIdentifier", validateEmptyOrNull(p.getTransactionIdentifier()));
            payment.put("errorCode", validateEmptyOrNull(p.getErrorCode()));
            payment.put("errorMessage", validateEmptyOrNull(p.getErrorMessage()));
            payment.put("date", validateEmptyOrNull(p.getDate()));
            payment.put("hour", validateEmptyOrNull(p.getHour()));
            payment.put("authorizationCode", validateEmptyOrNull(p.getAuthorizationCode()));
            payment.put("operationNumber", validateEmptyOrNull(p.getOperationNumber()));
        }
        main.put("payment",payment);

        JSONObject features=new JSONObject();

        JSONArray contentarray=new JSONArray();
        if(r==null){
            JSONObject content = new JSONObject();
            content.put("name"," ");
            content.put("value"," ");
            contentarray.put(content);
        }else {
            for (int i = 0; i < r.length; i++) {
                JSONObject content = new JSONObject();
                content.put("name", validateEmptyOrNull(r[i].getName()));
                content.put("value", validateEmptyOrNull(r[i].getValue()));
                contentarray.put(content);
            }
        }
        features.put("reserved",contentarray);
        if(pq==null){
            JSONObject planquotadata=new JSONObject();
            planquotadata.put("plan"," ");
            planquotadata.put("quota"," ");
            planquotadata.put("quotaProcessed"," ");
            planquotadata.put("amount"," ");
            planquotadata.put("dueDate"," ");
            planquotadata.put("currency"," ");
            planquotadata.put("interest"," ");
            features.put("planQuotaData",planquotadata);
        }else{
            JSONObject planquotadata=new JSONObject();
            planquotadata.put("plan",validateEmptyOrNull(pq.getPlan()));
            planquotadata.put("quota",validateEmptyOrNull(pq.getQuota()));
            planquotadata.put("quotaProcessed",validateEmptyOrNull(pq.getQuotaProcessed()));
            planquotadata.put("amount",validateEmptyOrNull(pq.getAmount()));
            planquotadata.put("dueDate",validateEmptyOrNull(pq.getDueDate()));
            planquotadata.put("currency",validateEmptyOrNull(pq.getCurrency()));
            planquotadata.put("interest",validateEmptyOrNull(pq.getInterest()));
            features.put("planQuotaData",planquotadata);
        }
        main.put("features",features);
        return main.toString();
    }

    public String validateEmptyOrNull(String value){
        String rs="";
        if(value==null){
            rs=" ";
        }else {
            rs=value;
        }
        return rs;
    }


    public String createJsonResponseEmpty() throws JSONException {
    JSONObject main=new JSONObject();
    main.put("success",true);
    main.put("messageCode","999");
    main.put("message","Cancel Transaction");
    main.put("amount",text_amount);

    JSONObject payment=new JSONObject();
        payment.put("accepted", false);
        payment.put("resultCode", " ");
        payment.put("resultMessage", " ");
        payment.put("authorizationResult", " ");
        payment.put("referenceCode", " ");
        payment.put("brand", " ");
        payment.put("bin", " ");
        payment.put("lastPan", " ");
        payment.put("transactionIdentifier"," ");
        payment.put("errorCode", " ");
        payment.put("errorMessage", " ");
        payment.put("date", " ");
        payment.put("hour", " ");
        payment.put("authorizationCode"," ");
        payment.put("operationNumber", " ");
    main.put("payment",payment);
    JSONObject features=new JSONObject();
    JSONArray contentarray=new JSONArray();
        JSONObject content = new JSONObject();
        content.put("name"," ");
        content.put("value"," ");
        contentarray.put(content);
    features.put("reserved",contentarray);
        JSONObject planquotadata=new JSONObject();
        planquotadata.put("plan"," ");
        planquotadata.put("quota"," ");
        planquotadata.put("quotaProcessed"," ");
        planquotadata.put("amount"," ");
        planquotadata.put("dueDate"," ");
        planquotadata.put("currency"," ");
        planquotadata.put("interest"," ");
    features.put("planQuotaData",planquotadata);
    main.put("features",features);
    return main.toString();
    }

}
