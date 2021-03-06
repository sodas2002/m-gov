/*
 * 
 * GAEQuery.java
 * ggm
 * 
 * Send Query to Google App Engine
 *
 * Copyright 2010 NTU CSIE Mobile & HCI Lab
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package tw.edu.ntu.mgov1999.gae;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.google.android.maps.GeoPoint;

//import com.google.android.maps.GeoPoint;

import tw.edu.ntu.mgov1999.mgov;
import tw.edu.ntu.mgov1999.net.ReadUrl;

public class GAEQuery {

	private final static String prefixURL = "http://ntu-ecoliving.appspot.com/";
	private final static String dbstr[] = { "czone/query/", "case/query/" };
	
	private int sourceTotalLength;
	
	public static enum GAEQueryCondtionType {
		GAEQueryByID,
		GAEQueryByEmail,
		GAEQueryByCoordinate,
		GAEQueryByType,
		GAEQueryByStatus
	}
	
	public static enum GAEQueryDatabase {
		GAEQueryDatabaseCzone,
		GAEQueryDatabaseCase
	}

	private String method, args;

	public GAEQuery() {
		method = "";
		args = "";
		sourceTotalLength = 0;
	}

	public GAECase getID(String id) throws JSONException {
		String res = ReadUrl.process(prefixURL + "czone/get_id/" + id, "utf-8");
		if (mgov.DEBUG_MODE)
			Log.d("GAEQuery", prefixURL + "czone/get_id/" + id);
		return new GAECase(new JSONObject(res));
	}

	public void addQuery(GAEQueryCondtionType type, String arg) {
		String conditionType = "";
		// Do not accept query by id in this way
		if (type==GAEQueryCondtionType.GAEQueryByID) return;
		else if (type==GAEQueryCondtionType.GAEQueryByEmail) conditionType = "email";
		else if (type==GAEQueryCondtionType.GAEQueryByCoordinate) conditionType = "coordinates";
		else if (type==GAEQueryCondtionType.GAEQueryByType) conditionType = "typeid";
		else if (type==GAEQueryCondtionType.GAEQueryByStatus) conditionType = "status";
		
		if (this.method != "")
			this.method += '&';
		if (this.args != "")
			this.args += '&';

		this.method += conditionType;
		this.args += arg;
	}

	// Overload
	public void addQuery(GAEQueryCondtionType conditionType, GeoPoint location, int latitudeSpanE6, int longitudeSpanE6) {
		// Accept for GAEQueryByCoordinate only
		if (conditionType!=GAEQueryCondtionType.GAEQueryByCoordinate) return;
		String locationString;
		locationString = Double.toString((double)(location.getLongitudeE6()/Math.pow(10, 6)));
		locationString += "&";
		locationString += Double.toString((double)(location.getLatitudeE6()/Math.pow(10,6)));
		locationString += "&";
		locationString += Double.toString((double)longitudeSpanE6/Math.pow(10, 6)/2.5);
		locationString += "&";
		locationString += Double.toString((double)latitudeSpanE6/Math.pow(10, 6)/2.5);
		this.addQuery(conditionType, locationString);
	}
	
	public GAECase[] doQuery(GAEQueryDatabase db, int start, int end) {
		int dbNumber=0;
		if (db==GAEQueryDatabase.GAEQueryDatabaseCzone) dbNumber=0;
		else if (db==GAEQueryDatabase.GAEQueryDatabaseCase) dbNumber=1;
		
		String queryStr = prefixURL + dbstr[dbNumber] + method + "/" + args + "/" + start + "/" + end;
		String jsonStr = ReadUrl.process(queryStr, "utf-8");
		
		if (mgov.DEBUG_MODE)
			Log.d("GAEQuery", queryStr);
		
		try {
			JSONObject ob = new JSONObject(jsonStr);

			if (ob.has("error"))
				return null;
			if (ob.has("length"))
				sourceTotalLength = ob.getInt("length");
			if (ob.has("result")) {
				JSONArray array = ob.getJSONArray("result");
				int len = array.length();
				GAECase res[] = new GAECase[len];

				for (int i = 0; i < len; i++) 
					res[i] = new GAECase(array.getJSONObject(i));
				return res;
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		return null;
	}
	
	public int getSourceTotalLength() {
		return this.sourceTotalLength;
	}
	
	public void resetCondition() {
		method = "";
		args = "";
		sourceTotalLength = 0;
	}

}
