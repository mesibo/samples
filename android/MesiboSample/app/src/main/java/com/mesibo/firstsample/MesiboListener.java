package com.mesibo.firstsample;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.support.v4.view.MenuItemCompat;
import android.view.Menu;
import android.view.MenuItem;

import com.mesibo.api.Mesibo;
import com.mesibo.calls.MesiboCall;

import java.util.ArrayList;

/**
 * Created by root on 2/22/18.
 */

public class MesiboListener implements Mesibo.UIHelperListner{
    /* [OPTIONAL] implement these methods if Mesibo UI is used
    * Refer to API documentation for more details
    * */
    @Override
    public void Mesibo_onForeground(Context context, int i, boolean b) {

    }

    @Override
    public void Mesibo_onShowProfile(Context context, Mesibo.UserProfile userProfile) {

    }

    @Override
    public void Mesibo_onDeleteProfile(Context context, Mesibo.UserProfile userProfile, Handler handler) {

    }

    @Override
    public int Mesibo_onGetMenuResourceId(Context context, int type, Mesibo.MessageParams params, Menu menu) {
        int id = 0;
        if (type == 0) // Setting menu in userlist
            id = R.menu.mesiboui_contacts_menu;
        else // from User messages
            id = R.menu.mesiboui_messages_menu;

        ((Activity)context).getMenuInflater().inflate(id, menu);

        /* Hide call icons for groups */
        if(1 == type && null != params && params.groupid > 0) {
            MenuItem menuItem = menu.findItem(R.id.action_call);
            menuItem.setVisible(false);
            MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);

            menuItem = menu.findItem(R.id.action_videocall);
            menuItem.setVisible(false);
            MenuItemCompat.setShowAsAction(menuItem, MenuItemCompat.SHOW_AS_ACTION_NEVER);
        }

        return 0;
    }

    @Override
    public boolean Mesibo_onMenuItemSelected(Context context, int type, Mesibo.MessageParams params, int item) {
        if (type == 0) { // from userlist
            if (item == R.id.action_settings) {
                /* Launch settings */
            }
        } else { // from messaging box
            if(R.id.action_call == item && 0 == params.groupid) {
                //UIManager.launchCallActivity(MainApplication.getAppContext(), params.peer, true);
                MesiboCall.getInstance().call(context, Mesibo.random(), params.profile, false);
            }
            else if(R.id.action_videocall == item && 0 == params.groupid) {
                //UIManager.launchCallActivity(MainApplication.getAppContext(), params.peer, true);
                MesiboCall.getInstance().call(context, Mesibo.random(), params.profile, true);
            }
        }
        return false;
    }

    @Override
    public void Mesibo_onSetGroup(Context context, long l, String s, int i, String s1, String s2, String[] strings, Handler handler) {

    }

    @Override
    public void Mesibo_onGetGroup(Context context, long l, Handler handler) {

    }

    @Override
    public ArrayList<Mesibo.UserProfile> Mesibo_onGetGroupMembers(Context context, long l) {
        return null;
    }
}
