procedure iud_itemtran_head(a_frame_name varchar2,a_table_name varchar2,a_iud_flag varchar2,a_ws_seqid number,a_iud_seqid number,a_row_slno number,a_testing_flag varchar2 default null) is  
    l_global_required_column_str varchar(4000) := '';
    l_vrno varchar2(16) := '';
    l_error varchar2(1000) := '';
    l_fkey_column_str varchar2(32000) := '';
    l_new_entry number := 1;
    l_update_where_col_str varchar2(1000) := '#ENTITY_CODE#TCODE#VRNO#';
    l_cur_lhsgtt_iud sys_refcursor;
    l_mode varchar2(5);
    l_check number;
    l_cnt number;
    l_user_code varchar2(20);
    l_app_remark varchar2(200);
    l_nn1 number;
    l_save_flag varchar2(20);
    l_object_code varchar2(30); 
    l_series_vr_prefix varchar2(100);
    l_mast_column varchar2(100);
    l_mast_code varchar2(100);
    l_purchase_dept_approval varchar2(30);
    l_call_mode varchar2(15);
    l_tnature varchar2(5);
begin  
  --    lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-0');
    select count(*) into l_check
    from lhsgtt_iud
    where table_name=upper(a_table_name) and iud_flag in ('i','N');
  
     select count(*) into l_cnt
    from lhswma_iud_msg_log t 
    where t.ws_seqid=a_ws_seqid and msg_type='MS' and validation_name='RUN_IUD';
    
    --  lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-01');
    if l_check > 0 and l_cnt =0 then        
      open l_cur_lhsgtt_iud for
      select a.row_slno, a.table_name, count(*) cnt
      from lhsgtt_iud a
      where a.ws_seqid=a_ws_seqid and a.iud_seqid=a_iud_seqid and a.table_name=a_table_name
      group by a.row_slno, a.table_name;
         --    lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-02');
      set_lhsgtt_iud_value(a_ws_seqid,a_iud_seqid,a_row_slno,a_table_name,a_frame_name,'BOTH');  
      l_mode:=iud_value(a_frame_name,'P_MODE');
      l_user_code:=iud_value(a_frame_name,'G_USER_CODE'); 
      l_object_code:=iud_value(a_frame_name,'OBJECT_CODE');
      l_purchase_dept_approval:=iud_value(a_frame_name,'P_PURCHASE_DEPT_APPROVAL');
       l_call_mode := iud_value(a_frame_name,'P_CALL_MODE');
       l_tnature   := iud_value(a_frame_name,'P_TNATURE');
         -- lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-03'); 
     if a_iud_flag <> 'D' then  
         -----------------------
     for i in (select a.row_slno, a.table_name, count(*) cnt
     from lhsgtt_iud a
     where a.ws_seqid=a_ws_seqid and a.iud_seqid=a_iud_seqid and a.table_name=a_table_name
     group by a.row_slno, a.table_name order by 1) loop       
      
             l_global_required_column_str:=null;
             l_global_required_column_str:=lhs1_global_req_column.req_itemtran_head(a_frame_name,a_table_name,a_ws_seqid,a_iud_seqid,i.row_slno,iud.tnature,l_cur_lhsgtt_iud);  
             l_global_required_column_str:= l_global_required_column_str||'#ENTITY_CODE#TCODE#TNATURE#SERIES#ACC_YEAR#VRDATE#';
             lhs1_global_valid.chk_required_column(l_global_required_column_str, a_table_name, a_ws_seqid,i.row_slno,a_iud_seqid);
          
    end loop;
     -----------------------
         l_fkey_column_str:='#ENTITY_CODE#TNATURE#AMENDBY#TRANTYPE#ACC_CODE#SUB_ACC_CODE#CONSIGNEE_CODE#EMP_CODE#BROKER_CODE#BROKERAGE_BASIS#BILL_PASS_TYPE#PAYMENT_MODE#TRPT_CODE#FREIGHT_BASIS#FROM_PLACE#TO_PLACE#TRUCKTYPE#VEHICLE_TYPE#ADDON_CODE#STAX_CODE#ETAX_CODE#FILE_CODE#CURRENCY_CODE#ADVANCE_BASIS#CREATEDBY#APPROVEDBY#CLOSED_FLAG#CLOSEDBY#USER_CODE#ACC_BANK_SLNO#BILLING_ACC_SLNO#BILLING_ENTITY_SLNO#BOM_ID#CNTR_CODE#CONSIGNEE_ACC_SLNO#DISPATCH_ENTITY_SLNO#LIFTER_CODE#SHIFT_CODE#SHIPPING_ACC_SLNO#TDSACC_CODE#TDS_CODE#VALUATIONBY#';
         l_fkey_column_str:=l_fkey_column_str||'ACC_TRAN_REF#HEAD_DIV_CODE_REF#SERIES_REF#';
         LHS1_GLOBAL_VALID.chk_fkey(a_ws_seqid,a_iud_seqid,a_row_slno,a_frame_name,a_table_name,l_fkey_column_str);
         lhs_global.insert_lhsgtt_iud(a_ws_seqid,a_table_name,a_iud_seqid,Null,'IOBJECT_CODE',l_object_code); 
      end if; 
       
     --  lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-1');
       
      if iud.vrno is not null then
         l_vrno := iud.vrno;
         l_new_entry := 0;      
      else
         if iud.entity_code is not null and iud.acc_year is not null and iud.tcode is not null and iud.series is not null and iud.vrdate is not null then
            l_new_entry := 1;
            l_mast_column :=lhs_global.get_vrprefix(iud.entity_code, iud.acc_year, iud.tcode, iud.series);
              --- lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-1.1');
             if l_mast_column is not null then
               l_mast_code:=nvl(iud_value(a_frame_name,l_mast_column),iud_value('B',l_mast_column)); 
               l_series_vr_prefix:=lhs_global.get_vrprefix(iud.entity_code, iud.acc_year, iud.tcode, iud.series,l_mast_column,l_mast_code);
             end if;
                        --    lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-1.2');
             l_vrno:=lhs_global.get_vrno(iud.entity_code, iud.acc_year, iud.tcode, iud.series, iud.vrdate,l_series_vr_prefix , l_user_code );
                       --     lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-1.3');
             lhs_global.insert_lhsgtt_iud(a_ws_seqid,a_table_name,a_iud_seqid,Null,'VRNO',l_vrno);
                           -- lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-1.4');
         else
            null;
         end if;
      end if;  
         ---    lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-2');
      if a_iud_flag <> 'D' then          
         lhs1_global.chk_keyword(a_ws_seqid,a_iud_seqid,a_row_slno,null,a_frame_name,a_table_name);       
      end if;
      
      if l_mode='AP' then
         if nvl(l_purchase_dept_approval,'TRUE')='FALSE' then
            lhs_global.insert_lhsgtt_iud(a_ws_seqid,a_table_name,a_iud_seqid,Null,'APPROVEDBY',l_user_code); 
            lhs_global.insert_lhsgtt_iud(a_ws_seqid,a_table_name,a_iud_seqid,Null,'APPROVEDDATE','','DATETIME'); 
         else 
            l_app_remark:=iud_value(a_frame_name,'APP_REMARK');        
            lhs_global.auto_approval_process(a_ws_seqid,a_iud_seqid,a_iud_flag,a_row_slno,a_table_name,iud.entity_code,iud.tcode,iud.vrno,null,iud.tnature,l_user_code,'A',l_app_remark,null,iud.series) ;      
         end if;
      end if;
            -- lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MS','IUD_ITEMTRAN_HEAD','REACHED-3');
     if a_iud_flag in ('I', 'U', 'D') then    
        lhs_global.run_iud(a_table_name=>'itemtran_head',a_iud_flag=>a_iud_flag,a_ws_seqid=>a_ws_seqid,a_iud_seqid=>a_iud_seqid,a_row_slno=>a_row_slno,a_update_where_col_str=>l_update_where_col_str);
     end if;         
     if a_iud_flag ='I' then
        l_save_flag :=' saved ';
     elsif a_iud_flag ='U' then
        l_save_flag :=' updated ';
     elsif a_iud_flag ='D' then
        l_save_flag :=' deleted '; 
     elsif  l_mode ='UA' then
          l_save_flag :=' Unapproved '; 
     end if;
     select count(*) into l_error from lhswma_iud_msg_log l where l.iud_seqid=a_iud_seqid and l.ws_seqid=a_ws_seqid and l.msg_type='MS' ;           
     if to_number(l_error)=0 then 
        if a_iud_flag in ('I') then
           if l_new_entry=1 then
              lhs_global.append_vrno(iud.entity_code,iud.acc_year,iud.tcode,l_vrno,l_user_code);  
           end if ;   
           lhs_global.fms(a_ws_seqid,a_iud_seqid,a_row_slno,a_table_name,a_frame_name,null);
        end if;  
        if l_mode in ('A', 'E', 'D') then 
          
           lhs_global.proc_user_appr_tran(a_frame_name,a_table_name,a_iud_flag,a_ws_seqid,a_iud_seqid,a_row_slno,null) ;             
      
        elsif l_mode='AP' then
           if iud.tnature in ('SALE','PURI','EXPN') then
              select count(*) into l_nn1 
              from itemtran_head h
              where h.entity_code=iud.entity_code and h.tcode=iud.tcode and h.vrno=iud.vrno and h.approvedby is not null ;
              if nvl(l_nn1,0)>0 then
                 acc_posting(a_frame_name,a_table_name,a_iud_flag,a_ws_seqid,a_iud_seqid,a_row_slno);                
                 l_nn1:=reverse_posting(a_frame_name,a_table_name,a_iud_flag,a_ws_seqid,a_iud_seqid,a_row_slno);
                 if iud.tnature ='EXPN' then
                    tds_posting('B','ITEMTRAN_BODY',a_iud_flag,a_ws_seqid,a_iud_seqid,null);
                 end if;
                 if l_nn1=0 then
                    lhs_wma.msg_log('IUD', a_ws_seqid, a_row_slno, 'MS', 'IUD_ITEMTRAN_HEAD', 'Posting Error from insert posting function', sqlerrm);
                 end if;
              end if ;                
           end if;   
       
            
        end if;        
        select count(*) into l_error from lhswma_iud_msg_log l where l.iud_seqid=a_iud_seqid and l.ws_seqid=a_ws_seqid and l.msg_type='MS' ;           
        if to_number(l_error)=0 then         
           lhs_wma.msg_log('IUD',a_ws_seqid,a_row_slno,'MI','IUD_ITEMTRAN_HEAD','Voucher number ' || l_vrno ||l_save_flag||' sucessfully in ' || a_table_name || ' table!'||a_ws_seqid);
        end if ;
     end if;   
     close l_cur_lhsgtt_iud;  
   end if; 
  exception when others then
      lhs_wma.msg_log('IUD', a_ws_seqid, a_row_slno, 'MS', 'IUD_ITEMTRAN_HEAD', 'itemtran_head : Not updated (procedure error)...' || sqlerrm, null);
      close l_cur_lhsgtt_iud;
  end iud_itemtran_head;