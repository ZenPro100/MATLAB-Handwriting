function [ labels_per_stroke , labels_per_sample ] = classify_diacritic_marks( Word )

   
    Line_List = segment_by_lines(Word);
    all_features = [];
    
    for j=1:length(Line_List)

        [ ~ , ~ , pendown_segments ]   = segment_by_penups_pendowns( Line_List(j) );
        [ ~ , ~ , ~ , ~ , ~ , Canonical_Lines ] = compute_canonical_lines_height_estimates_with_local_min_max( Line_List(j) , 1 , true );         
      
        for k=1:length(pendown_segments)
            features  = compute_diacritic_marks_features_for_classifier( pendown_segments(k) , Canonical_Lines );
            all_features = [ all_features; features ];
        end

    end
    
    load('SVM_diacritic_marks_model.mat')
    
    
    [labels_on_tablet , NegLoss , PBScore , Posterior ] = predict( SVM_diacritic_marks_model , all_features );
    
    [ all_segments , ~ , ~ ]   = segment_by_penups_pendowns( Word );
    labels_per_stroke = {};   
    labels_per_sample = {};
    idx_stroke = 1;
    idx_sample = 1;
    for k=1:length(all_segments)
        C    = cell( all_segments(k).NumSamples , 1 );
        if(strcmp(all_segments(k).Tracking,'ON_TABLET'))
            labels_per_stroke{k} = labels_on_tablet{idx_stroke};
            
            C(:) = { labels_on_tablet{idx_stroke} };
            labels_per_sample( idx_sample:(idx_sample + all_segments(k).NumSamples -1 ) ) = C;
            idx_stroke = idx_stroke + 1;
        else
            labels_per_stroke{k} = 'normal';
            
            C(:) = {'normal'};
            labels_per_sample( idx_sample:(idx_sample + all_segments(k).NumSamples -1 ) ) = C;
        end
        
        idx_sample = idx_sample + all_segments(k).NumSamples;
    end
    

end