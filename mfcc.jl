function hamming_window(sig)
	y = zeros(size(sig))
	alpha = 0.54
	beta = 1-alpha
	N = length(sig)-1

	for n=1:length(sig)
		y[n] = sig[n]*(alpha - beta*cos( 2.0*pi*n / (N-1) ))
	end

	return y
end
	
function triangle_filterbank(nfilt,nfft,Hz)

	f_low = 0
	f_hi  = 8000
	m_low = 2595*log(1 + f_low/700)
	m_hi  = 2595*log(1 + f_hi/700)
	m = linspace(m_low,m_hi,nfilt+2)
	h = 700*(exp(m./2595)-1) 
	f = map(int, floor((nfft+1)*h./Hz+1))

	H = zeros( nfilt, int(nfft/2+1) )


	for j=[1:nfilt]
		for i=[f[j]:f[j+1]]
			H[j,i] = (i - f[j])/(f[j+1]-f[j])
		end
		for i=[f[j+1]:f[j+2]]
			H[j,i] = (f[j+2]-i)/(f[j+2]-f[j+1])
		end
	end


	return H
end

function frame_speech(speech,frame_len,frame_step)
	MN = size(speech)

	if MN[1] > MN[2]
		speech = speech.'
	end
	
	len = length(speech)
	frame_len = int(round(frame_len))
	frame_step = int(round(frame_step))

	println("Frame step: ",frame_step)
	println("Frame len: ",frame_len)

	if len <= frame_len

		num_frames = 1
	else
		num_frames = int(1 + ceil((len-frame_len)/frame_step))
	end
	
	println("Num frames: ",num_frames)

	padd_len = int((num_frames-1)*frame_step + frame_len)
	padding = zeros(1,(padd_len - len))


	speech = hcat(speech,padding)
	
	
	start = 1 
	stop = frame_len 

	frames = zeros(num_frames,frame_len)

	for i=1:num_frames
		frames[i,:] = vec(speech[start:stop])'
		start += frame_step
		stop += frame_step
	end
	
	return frames
end

function power_spectra(frames,nfft=0)

	MN = size(frames)


	if nfft == 0
		nfft = int(ceil(log2(MN[2])))
	end

	if nfft - MN[2] > 0
		println("Padding frames for FFT: ",MN[2]," -> ",nfft)
		frames = hcat(frames,zeros(MN[1],nfft-MN[2]))
	end


	F  = 1/nfft*(abs(rfft(frames,2)).^2)

	return F

end

function preemphasis(speech,alpha=0.95)
	return hcat(vec([speech[1]]),vec(speech[2:end]-alpha*speech[2:end]).')
end
	

function lifter(cepstra,L=22)
	MN = size(cepstra)
	lifty = [0:MN[2]-1]
	lifty = 1+((L-1)/2)*sin(pi*lifty/(L-1))
	for i=1:MN[1]
		cepstra[i,:] = cepstra[i,:].*(lifty')
	end

	return cepstra 

end

function mfcc(speech,Hz=16000)

	println("Hz ",Hz)

	speech = preemphasis(speech)

	# ------------------
	# Windowing
	# ------------------

	# frame size: 25 ms <--> X samples @ Hz
	frame_len = 0.025*Hz
	
	# overlap 10ms <--> Y samples @ Hz
	frame_step = 0.01*Hz

	frames = frame_speech( speech, frame_len, frame_step )

	println("Frame matrix: ",size(frames))


	# ------------------
	# Power spectra 
	# ------------------
	nfft = int(2^ceil(log2( size(frames)[2] )))
	spectra = power_spectra( frames, nfft )
	energy = 1e10*sum(spectra,2)


	# ------------------
	# Triangle filter 
	# ------------------

	nfilt = 20
	H = triangle_filterbank(nfilt,nfft,Hz)

	
	# ------------------
	# Compute MFCCs 
	# ------------------


	M = spectra * H'
	logMel = log(M.*1e12)

	numcep = 13
	MFCC = dct(logMel,2)
	MFCC = lifter(MFCC)
	MFCC[:,1] = log(energy)

	# TODO add energy
	result = MFCC[:,1:numcep]

	return result 
end

function delta_coeff(ct,N=2)

	MN = size(ct)
	delta = zeros(MN)

	for i=1:MN[1]
		for t=1:MN[2]
			
			dt = 0.0
			for n=1:N
				tpn = t+n < MN[2] ? t+n : MN[2]
				tmn = t-n > 1 ? t-n : 1
				dt += n*(ct[i,tpn]-ct[i,tmn])/n^2
			end
			dt = dt*0.5

			delta[i,t] = dt
		end
	end

	return delta

end

