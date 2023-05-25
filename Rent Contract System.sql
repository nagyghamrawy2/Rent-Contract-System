create or replace procedure add_installments_paid
is
        
                    cursor data_cursor is
                    select  *
                    from CLIENTS clt inner join contracts con
                    on CLT.CLIENT_ID = con.client_id; 
                v_count number(4);
                v_installment_date date; 
                no_of_installments number(10,2);
                v_total_installments number(10,2);
                v_installment_amount number(10,2);   
                v_sum number(10,2);    
                v_max_date date;    

begin

        for data_record in data_cursor loop
                    v_total_installments := data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0);
                    select nvl(max(v_installment_date) , min(data_record.contract_startdate)) into v_max_date from installments_paid where contract_id = data_record.contract_id; 
                     select nvl(sum(v_installment_amount) ,0) into v_sum from installments_paid where contract_id = data_record.contract_id;
                    if data_record.contract_payment_type = 'ANNUAL' then
                                    no_of_installments :=  trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/12);
                    elsif data_record.contract_payment_type = 'QUARTER' then
                                    no_of_installments :=  months_between(data_record.contract_enddate , data_record.contract_startdate)/3;
                    elsif data_record.contract_payment_type = 'HALF_ANNUAL' then
                                    no_of_installments :=  months_between(data_record.contract_enddate , data_record.contract_startdate)/6;  
                    else
                                    no_of_installments :=  months_between(data_record.contract_enddate , data_record.contract_startdate);                                           
                    end if;        
                     v_installment_amount := v_total_installments / no_of_installments;
                     v_installment_date := data_record.contract_startdate;
                     for i in 1..no_of_installments   loop
                     if  v_sum <= data_record.contract_total_fees then
                                             insert into installments_paid 
                                             values  (INSTALLMENTS_PAID_SEQ.nextval , data_record.contract_id , v_installment_date  , v_installment_amount  , 0 ) ; 
                                             v_total_installments := v_total_installments - v_installment_amount;
                                             if data_record.contract_payment_type = 'ANNUAL' then
                                                    v_installment_date := add_months( v_installment_date , 12);
                                             elsif data_record.contract_payment_type = 'QUARTER' then
                                                      v_installment_date := add_months( v_installment_date , 3);       
                                             elsif data_record.contract_payment_type = 'HALF_ANNUAL' then
                                                      v_installment_date := add_months( v_installment_date , 6);                                                 
                                             else
                                                      v_installment_date := add_months( v_installment_date , 1);                                                
                                             end if;
                    end if;                         
                    end loop;
        
        end loop;

end;
show errors;