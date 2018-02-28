package com.mesibo.firstsample;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.mesibo.firstsample.databinding.LayoutMessageShowBinding;

import java.util.ArrayList;

public class DemoActivityMessageAdapter extends RecyclerView.Adapter<DemoActivityMessageAdapter.ViewHolder> {

    private ArrayList<DemoActivityMessageHolder> demoActivityMessageHolderList = null;
    public DemoActivityMessageAdapter(ArrayList<DemoActivityMessageHolder> demoActivityMessageHolderList){
    this.demoActivityMessageHolderList = demoActivityMessageHolderList;
    }
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        LayoutMessageShowBinding mBinding = LayoutMessageShowBinding.inflate(LayoutInflater.from(parent.getContext()),parent,false);
        return new ViewHolder(mBinding);
    }
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (demoActivityMessageHolderList.get(position).isSentMessage() == true){
            holder.mBinding.cardviewSendMesssage.setVisibility(View.VISIBLE);
            holder.mBinding.textviewMsgSend.setText(demoActivityMessageHolderList.get(position).getMessage());
            holder.mBinding.textviewSendTime.setText(demoActivityMessageHolderList.get(position).getTime());
        }else{
            holder.mBinding.cardviewReciveMesssage.setVisibility(View.VISIBLE);
            holder.mBinding.textviewMsgRecive.setText(demoActivityMessageHolderList.get(position).getMessage());
            holder.mBinding.textviewReciveTime.setText(demoActivityMessageHolderList.get(position).getTime());
        }
        holder.setIsRecyclable(false);
    }
    @Override
    public int getItemCount() {
        return demoActivityMessageHolderList.size();
    }
    public class ViewHolder extends RecyclerView.ViewHolder {
        public LayoutMessageShowBinding mBinding = null;
        public ViewHolder(LayoutMessageShowBinding mBinding) {
            super(mBinding.getRoot());
            this.mBinding = mBinding;
        }
    }
}